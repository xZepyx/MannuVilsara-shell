import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.Core
import qs.Services
import "../../Services" as LocalServices

WlSessionLockSurface {
    id: root

    required property var lock
    required property var pam
    required property var colors

    color: "black"

    // System info service for neofetch
    LocalServices.SystemInfoService {
        id: sysInfo
    }

    // Blurred window preview background
    ScreencopyView {
        id: bg
        anchors.fill: parent
        captureSource: root.screen
        opacity: 0
        Component.onCompleted: opacity = 1
        layer.enabled: visible && opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 800; easing.type: Easing.OutQuad }
        }

        layer.effect: FastBlur {
            radius: 48
            transparentBorder: true
        }
    }

    // Dark overlay
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.45
    }

    // Main Bento Grid Container - 3 columns, 2 rows
    Item {
        id: bentoContainer
        anchors.centerIn: parent
        width: Math.min(parent.width - 60, 920)
        height: Math.min(parent.height - 80, 480)
        scale: 0.85
        opacity: 0

        ParallelAnimation {
            running: true
            NumberAnimation { target: bentoContainer; property: "scale"; to: 1; duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
            NumberAnimation { target: bentoContainer; property: "opacity"; to: 1; duration: 400; easing.type: Easing.OutCubic }
        }

        // Grid Layout - 3 columns
        RowLayout {
            anchors.fill: parent
            spacing: 12

            // LEFT COLUMN
            ColumnLayout {
                Layout.preferredWidth: (parent.width - 24) * 0.30
                Layout.fillHeight: true
                spacing: 12

                // Clock Card (top-left)
                BentoCard {
                    id: clockCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cardColor: root.colors.surface
                    borderColor: root.colors.border
                    animDelay: 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        Text {
                            text: Qt.formatTime(new Date(), "hh")
                            font.pixelSize: 72
                            font.weight: Font.Black
                            color: root.colors.accent
                            Layout.alignment: Qt.AlignHCenter
                            lineHeight: 0.85
                            Timer { interval: 1000; running: true; repeat: true; onTriggered: parent.text = Qt.formatTime(new Date(), "hh") }
                        }

                        Text {
                            text: Qt.formatTime(new Date(), "mm")
                            font.pixelSize: 72
                            font.weight: Font.Black
                            color: root.colors.fg
                            Layout.alignment: Qt.AlignHCenter
                            lineHeight: 0.85
                            Timer { interval: 1000; running: true; repeat: true; onTriggered: parent.text = Qt.formatTime(new Date(), "mm") }
                        }

                        Text {
                            text: Qt.formatDate(new Date(), "ddd, MMM d")
                            font.pixelSize: 13
                            color: root.colors.muted
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 12
                        }
                    }
                }

                // Music Card (bottom-left)
                BentoCard {
                    id: musicCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    cardColor: root.colors.surface
                    borderColor: root.colors.border
                    animDelay: 100
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: MprisService.artUrl
                        fillMode: Image.PreserveAspectCrop
                        visible: MprisService.artUrl !== ""
                        opacity: 0.15
                        layer.enabled: visible
                        layer.effect: FastBlur { radius: 40 }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        Rectangle {
                            Layout.preferredWidth: 60
                            Layout.preferredHeight: 60
                            radius: 12
                            color: root.colors.tileActive
                            clip: true

                            Image {
                                anchors.fill: parent
                                source: MprisService.artUrl
                                fillMode: Image.PreserveAspectCrop
                                visible: MprisService.artUrl !== ""
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰎈"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 24
                                color: root.colors.muted
                                visible: MprisService.artUrl === ""
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                text: MprisService.title || "No Media"
                                color: root.colors.fg
                                font.pixelSize: 12
                                font.bold: true
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: MprisService.artist || ""
                                color: root.colors.muted
                                font.pixelSize: 10
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            RowLayout {
                                spacing: 12
                                Layout.topMargin: 4

                                Repeater {
                                    model: [
                                        { icon: "󰒮", action: function() { MprisService.previous() }, size: 14 },
                                        { icon: MprisService.isPlaying ? "󰏤" : "󰐊", action: function() { MprisService.playPause() }, size: 18, accent: true },
                                        { icon: "󰒭", action: function() { MprisService.next() }, size: 14 }
                                    ]

                                    Text {
                                        required property var modelData
                                        text: modelData.icon
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: modelData.size
                                        color: modelData.accent ? root.colors.accent : root.colors.fg
                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.margins: -6
                                            onClicked: modelData.action()
                                            cursorShape: Qt.PointingHandCursor
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // CENTER COLUMN
            ColumnLayout {
                Layout.preferredWidth: (parent.width - 24) * 0.40
                Layout.fillHeight: true
                spacing: 12

                // Neofetch Card (top-center)
                BentoCard {
                    id: neofetchCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cardColor: root.colors.surface
                    borderColor: root.colors.border
                    animDelay: 50

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 20

                        Text {
                            text: "󰣇"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 80
                            color: root.colors.accent
                        }

                        ColumnLayout {
                            spacing: 3

                            Text {
                                text: sysInfo.userName + "@" + sysInfo.hostName
                                font.bold: true
                                font.pixelSize: 14
                                color: root.colors.blue
                                font.family: "JetBrainsMono Nerd Font"
                            }

                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: root.colors.subtext
                                opacity: 0.4
                                Layout.bottomMargin: 4
                            }

                            Repeater {
                                model: [
                                    { label: "OS", key: "osName", icon: "", color: root.colors.blue },
                                    { label: "Host", key: "hostName", icon: "", color: root.colors.purple },
                                    { label: "Kernel", key: "kernelVersion", icon: "", color: root.colors.green },
                                    { label: "Uptime", key: "uptime", icon: "", color: root.colors.yellow },
                                    { label: "Shell", key: "shellName", icon: "", color: root.colors.orange },
                                    { label: "WM", key: "wmName", icon: "", color: root.colors.red }
                                ]

                                RowLayout {
                                    required property var modelData
                                    spacing: 8

                                    Text {
                                        text: modelData.icon
                                        color: modelData.color
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 11
                                    }

                                    Text {
                                        text: modelData.label + ":"
                                        color: modelData.color
                                        font.bold: true
                                        font.pixelSize: 11
                                        font.family: "JetBrainsMono Nerd Font"
                                    }

                                    Text {
                                        text: sysInfo[modelData.key] || "..."
                                        color: root.colors.fg
                                        font.pixelSize: 11
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                            }

                            RowLayout {
                                Layout.topMargin: 6
                                spacing: 4

                                Repeater {
                                    model: [root.colors.red, root.colors.green, root.colors.yellow, root.colors.blue, root.colors.purple, root.colors.teal]

                                    Rectangle {
                                        required property color modelData
                                        width: 18
                                        height: 10
                                        radius: 2
                                        color: modelData
                                    }
                                }
                            }
                        }
                    }
                }

                // Password Card (bottom-center)
                BentoCard {
                    id: passwordCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    cardColor: root.colors.surface
                    borderColor: inputField.activeFocus ? root.colors.accent : root.colors.border
                    animDelay: 150

                    Behavior on borderColor { ColorAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        width: parent.width - 40

                        RowLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 12

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 24
                                color: root.colors.tileActive
                                border.width: 2
                                border.color: root.colors.accent

                                Image {
                                    id: avatarImg
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    source: "file://" + Quickshell.env("HOME") + "/.face"
                                    fillMode: Image.PreserveAspectCrop
                                    layer.enabled: status === Image.Ready
                                    layer.effect: OpacityMask {
                                        maskSource: Rectangle { width: avatarImg.width; height: avatarImg.height; radius: width / 2 }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰀄"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 22
                                    color: root.colors.muted
                                    visible: avatarImg.status !== Image.Ready
                                }
                            }

                            Text {
                                text: Quickshell.env("USER") || "User"
                                color: root.colors.fg
                                font.pixelSize: 14
                                font.bold: true
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 40
                            radius: 20
                            color: Qt.rgba(0, 0, 0, 0.4)
                            border.width: 1
                            border.color: inputField.activeFocus ? root.colors.accent : "transparent"

                            TextInput {
                                id: inputField
                                property int shakeOffset: 0
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                verticalAlignment: TextInput.AlignVCenter
                                horizontalAlignment: TextInput.AlignHCenter
                                color: root.colors.fg
                                font.pixelSize: 14
                                font.letterSpacing: 3
                                echoMode: TextInput.Password
                                passwordCharacter: "●"
                                focus: true
                                Component.onCompleted: forceActiveFocus()
                                onAccepted: { if (text.length > 0) { root.pam.submit(text); text = "" } }
                                x: anchors.leftMargin + shakeOffset

                                Text {
                                    anchors.centerIn: parent
                                    text: "Enter password"
                                    color: root.colors.muted
                                    font.pixelSize: 12
                                    visible: !parent.text && !parent.activeFocus
                                }

                                SequentialAnimation {
                                    id: shakeAnim
                                    loops: 2
                                    PropertyAnimation { target: inputField; property: "shakeOffset"; to: 10; duration: 50 }
                                    PropertyAnimation { target: inputField; property: "shakeOffset"; to: -10; duration: 50 }
                                    PropertyAnimation { target: inputField; property: "shakeOffset"; to: 0; duration: 50 }
                                }

                                Connections {
                                    target: root.pam
                                    function onFailure() { shakeAnim.start(); inputField.color = root.colors.urgent; failTimer.start() }
                                    function onError() { shakeAnim.start(); inputField.color = root.colors.urgent; failTimer.start() }
                                }

                                Timer { id: failTimer; interval: 1000; onTriggered: inputField.color = root.colors.fg }
                            }
                        }
                    }
                }
            }

            // RIGHT COLUMN
            ColumnLayout {
                Layout.preferredWidth: (parent.width - 24) * 0.30
                Layout.fillHeight: true
                spacing: 12

                // System Stats Card (top-right)
                BentoCard {
                    id: statsCard
                    Layout.fillWidth: true
                    Layout.preferredHeight: 130
                    cardColor: root.colors.surface
                    borderColor: root.colors.border
                    animDelay: 100

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 12

                        Text {
                            text: "System"
                            color: root.colors.fg
                            font.pixelSize: 12
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        RowLayout {
                            spacing: 20
                            Layout.alignment: Qt.AlignHCenter

                            ProgressRing {
                                width: 50; height: 50
                                progress: 0.5
                                ringColor: root.colors.accent
                                bgColor: root.colors.muted
                                label: "CPU"
                                textColor: root.colors.fg
                                mutedColor: root.colors.muted
                            }

                            ProgressRing {
                                width: 50; height: 50
                                progress: 0.6
                                ringColor: root.colors.secondary
                                bgColor: root.colors.muted
                                label: "RAM"
                                textColor: root.colors.fg
                                mutedColor: root.colors.muted
                            }
                        }
                    }
                }

                // Notifications Card (bottom-right, fills remaining space)
                BentoCard {
                    id: notifCard
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    cardColor: root.colors.surface
                    borderColor: root.colors.border
                    animDelay: 200

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Text {
                            text: "Notifications"
                            color: root.colors.fg
                            font.pixelSize: 12
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: root.colors.border
                            opacity: 0.5
                        }

                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "󰂚"
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 32
                                    color: root.colors.muted
                                    opacity: 0.4
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Text {
                                    text: "All caught up"
                                    color: root.colors.muted
                                    font.pixelSize: 11
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Reusable Bento Card Component
    component BentoCard: Rectangle {
        id: card
        property color cardColor: "transparent"
        property color borderColor: "gray"
        property int animDelay: 0

        color: Qt.rgba(cardColor.r, cardColor.g, cardColor.b, 0.85)
        radius: 20
        border.width: 1
        border.color: borderColor
        opacity: 0
        transform: Translate { id: cardTranslate; y: 15 }

        SequentialAnimation {
            running: true
            PauseAnimation { duration: animDelay }
            ParallelAnimation {
                NumberAnimation { target: card; property: "opacity"; to: 1; duration: 350; easing.type: Easing.OutCubic }
                NumberAnimation { target: cardTranslate; property: "y"; to: 0; duration: 350; easing.type: Easing.OutCubic }
            }
        }
    }

    // Reusable Progress Ring Component
    component ProgressRing: Item {
        property real progress: 0.5
        property color ringColor: "white"
        property color bgColor: "gray"
        property string label: ""
        property color textColor: "white"
        property color mutedColor: "gray"

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d")
                ctx.reset()
                var cx = width / 2, cy = height / 2, r = 20, lw = 5
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, 2 * Math.PI)
                ctx.strokeStyle = Qt.rgba(bgColor.r, bgColor.g, bgColor.b, 0.25)
                ctx.lineWidth = lw
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(cx, cy, r, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress))
                ctx.strokeStyle = ringColor
                ctx.lineCap = "round"
                ctx.lineWidth = lw
                ctx.stroke()
            }
            Component.onCompleted: requestPaint()
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            Text { text: Math.round(progress * 100) + "%"; color: textColor; font.pixelSize: 10; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Text { text: label; color: mutedColor; font.pixelSize: 8; Layout.alignment: Qt.AlignHCenter }
        }
    }
}
