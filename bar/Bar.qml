import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../core"
import "../services"

Rectangle {
    id: barRoot
    anchors.fill: parent
    color: colors.bg // Base background

    // --- Properties ---
    required property Colors colors
    required property string fontFamily
    required property int fontSize
    required property string kernelVersion
    required property int cpuUsage
    required property int memUsage
    required property int diskUsage
    required property int volumeLevel
    required property string activeWindow
    required property string currentLayout
    required property string time

    component VerticalDivider: Rectangle {
        Layout.preferredWidth: 1
        Layout.preferredHeight: 12
        Layout.alignment: Qt.AlignVCenter
        color: colors.muted
        opacity: 0.5
    }

    component InfoPill: Rectangle {
        default property alias content: innerLayout.data
        Layout.preferredHeight: 26
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: innerLayout.implicitWidth + 24
        radius: height / 2

        color: colors.bg
        border.color: colors.muted
        border.width: 1

        RowLayout {
            id: innerLayout
            anchors.centerIn: parent
            spacing: 8
        }
    }

    // --- Main Layout ---
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        Rectangle {
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            radius: height / 2
            color: "transparent"

            Image {
                anchors.centerIn: parent
                width: 18
                height: 18
                source: "file:///etc/xdg/quickshell/mannu/assets/arch.svg"
                fillMode: Image.PreserveAspectFit
                opacity: 0.9
            }
        }

        VerticalDivider {}

        // --- WORKSPACES (Animated Carousel) ---
        Rectangle {
            id: wsContainer
            // 1. Container Size
            // 150px fits: [Semi-Circle] + [Active Pill] + [Circles] + [Semi-Circle]
            Layout.preferredWidth: 150
            Layout.preferredHeight: 28

            color: Qt.darker(colors.bg, 1.1)
            radius: height / 2

            // Clip is essential for the semi-circles to appear "cut off"
            clip: true

            ListView {
                id: wsList
                anchors.fill: parent

                orientation: ListView.Horizontal
                spacing: 6

                // 2. Sliding Logic (The "Back and Forth" Animation)
                // This aligns the Active Workspace to a specific "Sweet Spot" (pixel 12).
                // When you switch, the list physically slides left/right to put the new Active item at pixel 12.
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: 12
                preferredHighlightEnd: 138

                // Slower duration = Smoother slide effect
                highlightMoveDuration: 300
                highlightMoveVelocity: -1 // -1 means "ignore velocity, strictly use duration"

                // 3. Data Source
                currentIndex: (Hyprland.focusedWorkspace.id - 1)
                model: 20

                delegate: Rectangle {
                    id: wsDelegate
                    property int wsIndex: index + 1
                    property var workspace: Hyprland.workspaces.values.find(ws => ws.id === wsIndex) ?? null
                    property bool isActive: wsList.currentIndex === index
                    property bool hasWindows: workspace !== null

                    height: 18
                    anchors.verticalCenter: parent.verticalCenter

                    // 4. Width Animation (The "Jelly" Effect)
                    // Active = 36px, Inactive = 18px
                    width: isActive ? 36 : 18
                    radius: height / 2

                    // Colors
                    color: (isActive || hasWindows) ? colors.purple : "transparent"
                    border.color: (!isActive && !hasWindows) ? colors.muted : "transparent"
                    border.width: (!isActive && !hasWindows) ? 2 : 0

                    // 5. Enhanced Animations
                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            // Easing.OutBack creates a slight "overshoot" or bounce.
                            // This makes the pill feel like it "springs" open.
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.2
                        }
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: Hyprland.dispatch("workspace " + parent.wsIndex)
                        onWheel: {
                            if (wheel.angleDelta.y > 0) {
                                Hyprland.dispatch("workspace -1");
                            } else {
                                Hyprland.dispatch("workspace +1");
                            }
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        VerticalDivider {}

        Text {
            text: currentLayout
            color: colors.fg
            font.pixelSize: fontSize
            font.family: fontFamily
            font.bold: true
            opacity: 0.7
            Layout.leftMargin: 4
        }

        // =====================================
        // SPACER
        // =====================================
        Item {
            Layout.fillWidth: true
        }

        // =====================================
        // CENTER SECTION: Active Window
        // =====================================

        InfoPill {
            visible: activeWindow !== ""
            Layout.maximumWidth: 400

            Text {
                text: activeWindow
                color: colors.fg
                font.pixelSize: fontSize
                font.family: fontFamily
                font.bold: true
                elide: Text.ElideMiddle
                Layout.maximumWidth: 360
            }
        }

        // =====================================
        // SPACER
        // =====================================
        Item {
            Layout.fillWidth: true
        }

        // =====================================
        // RIGHT SECTION: System Stats
        // =====================================

        // InfoPill {
        //     // spacing: 12
        //     Row {
        //         spacing: 4
        //         Text { text: "CPU"; color: colors.yellow; font.bold: true; font.pixelSize: fontSize - 1 }
        //         Text { text: cpuUsage + "%"; color: colors.fg; font.pixelSize: fontSize; font.family: fontFamily }
        //     }
        //     VerticalDivider { Layout.preferredHeight: 10 }
        //     Row {
        //         spacing: 4
        //         Text { text: "RAM"; color: colors.cyan; font.bold: true; font.pixelSize: fontSize - 1 }
        //         Text { text: memUsage + "%"; color: colors.fg; font.pixelSize: fontSize; font.family: fontFamily }
        //     }
        // }
        //
        // InfoPill {
        //     Row {
        //         spacing: 6
        //         Text { text: "VOL"; color: colors.purple; font.bold: true; font.pixelSize: fontSize - 1 }
        //         Text {
        //             text: volumeLevel + "%"
        //             color: colors.fg
        //             font.pixelSize: fontSize
        //             font.family: fontFamily
        //             font.bold: true
        //         }
        //     }
        // }

        Rectangle {
            Layout.preferredHeight: 26
            Layout.preferredWidth: clockText.implicitWidth + 26
            radius: height / 2
            color: colors.purple

            Text {
                id: clockText
                anchors.centerIn: parent
                text: time
                color: colors.bg
                font.pixelSize: fontSize
                font.family: fontFamily
                font.bold: true
            }
        }
    }
}
