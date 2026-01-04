import "../Components"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Core

BentoCard {
    id: root

    required property var colors
    required property var pam
    property alias inputField: inputField

    // Make it look like a terminal window
    cardColor: "#1e1e2e" // Dark terminal bg
    borderColor: inputField.activeFocus ? root.colors.accent : root.colors.border

    // Blinking cursor timer
    Timer {
        id: cursorTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: cursor.visible = !cursor.visible
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8
        width: parent.width - 32

        // Terminal Header
        Text {
            text: Quickshell.env("USER") + "@" + (hostnameProc.hostname || "arch") + ":~$ auth"
            color: root.colors.accent 
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            Layout.alignment: Qt.AlignLeft
            visible: true
        }

        Process {
            id: hostnameProc
            property string hostname: ""
            command: ["cat", "/etc/hostname"]
            running: true
            stdout: SplitParser {
                onRead: (data) => hostnameProc.hostname = data.trim()
            }
        }

        // Input Line
        RowLayout {
            spacing: 0
            
            Text {
                text: "> "
                color: root.colors.secondary // Pink/Purple prompt
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                font.bold: true
            }

            TextMetrics {
                id: dotMetrics
                text: "•"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 20
                font.bold: true
            }

            Item {
                Layout.preferredWidth: inputField.text.length * dotMetrics.width
                Layout.preferredHeight: 30
                
                Behavior on Layout.preferredWidth {
                    NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
                }

                ListView {
                    id: dotList
                    anchors.fill: parent
                    orientation: ListView.Horizontal
                    layoutDirection: Qt.LeftToRight
                    interactive: false
                    displayMarginEnd: 1000
                    
                    property real dotWidth: dotMetrics.width
                    
                    model: inputField.text.length
                    
                    delegate: Text {
                        text: "•"
                        color: root.colors.fg
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 20
                        font.bold: true
                        
                        transform: Scale {
                            origin.x: ListView.view.dotWidth / 2
                            origin.y: 15
                        }
                    }

                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
                        NumberAnimation { property: "scale"; from: 0; to: 1; duration: 200; easing.type: Easing.OutBack }
                    }
                    
                    remove: Transition {
                        NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                        NumberAnimation { property: "scale"; to: 0; duration: 200 }
                    }
                }
            }

            // Blinking Cursor
            Rectangle {
                id: cursor
                Layout.preferredWidth: 10
                Layout.preferredHeight: 20
                color: root.colors.fg
                visible: true
            }
        }
        
        // Status/Error Message
        Text {
            id: statusText
            text: "" 
            color: root.colors.urgent
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            font.bold: true
            visible: text !== ""
            Layout.topMargin: 4
        }
    }

    // Hidden functionality
    TextInput {
        id: inputField
        anchors.fill: parent
        color: "transparent"
        cursorVisible: false
        selectionColor: "transparent"
        selectedTextColor: "transparent"
        cursorDelegate: Item {} // Render nothing
        focus: true
        Component.onCompleted: forceActiveFocus()
        
        onAccepted: {
            if (text.length > 0) {
                root.pam.submit(text);
                statusText.text = "authenticating..."
                statusText.color = root.colors.subtext
                text = "";
            }
        }
    }

    Connections {
        target: root.pam
        
        function onFailure() {
            statusText.text = "ACCESS DENIED"
            statusText.color = root.colors.urgent
            shakeAnim.start()
            resetTimer.start()
        }
        
        function onError() {
            statusText.text = "SYSTEM ERROR"
            statusText.color = root.colors.urgent
            shakeAnim.start()
            resetTimer.start()
        }
    }

    Timer {
        id: resetTimer
        interval: 2000
        onTriggered: {
            statusText.text = ""
        }
    }
    
    SequentialAnimation {
        id: shakeAnim
        loops: 3
        PropertyAnimation { target: root; property: "x"; from: root.x; to: root.x + 8; duration: 40 }
        PropertyAnimation { target: root; property: "x"; from: root.x + 8; to: root.x - 8; duration: 40 }
        PropertyAnimation { target: root; property: "x"; from: root.x - 8; to: root.x; duration: 40 }
    }
}
