import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: root

    // --- Inputs ---
    property var menuHandle: null
    property real menuX: 0
    property real menuY: 0
    property bool isOpen: false

    // Theme Interface
    property var colors: QtObject {
        property color bg: "#1e1e2e"       // Base
        property color fg: "#cdd6f4"       // Text
        property color accent: "#cba6f7"   // Mauve
        property color muted: "#45475a"    // Surface 1
        property color border: "#313244"   // Surface 0
    }

    function open(handle, x, y) {
        menuHandle = handle;
        
        let width = 240; 
        let estimatedHeight = 300;
        
        // Position menu to align with the bar (no gap)
        // Center the menu under the clicked icon
        let safeX = x - (width / 2);
        
        // Ensure menu stays within screen bounds
        safeX = Math.max(8, Math.min(safeX, Screen.width - width - 8));
        let safeY = y; // Use exact Y position (no gap)

        menuX = safeX;
        menuY = safeY-34;
        
        visible = true;
        isOpen = true;
    }

    function close() {
        isOpen = false;
        closeTimer.start();
    }

    Timer {
        id: closeTimer
        interval: 250 
        onTriggered: root.visible = false
    }

    // --- Window Setup ---
    color: "transparent"
    visible: false
    
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // FIX: PanelWindow anchors must be boolean flags
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Click-outside handler
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.close()
    }

    // --- Menu Container ---
    Item {
        id: menuContainer
        
        x: root.menuX
        y: root.menuY - 1
        width: 240
        
        // Animate height to slide down from bar
        clip: true
        height: root.isOpen ? menuBox.height : 0
        
        Behavior on height { 
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic } 
        }
        
        // Fade in as it slides
        opacity: root.isOpen ? 1.0 : 0.0
        Behavior on opacity { 
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad } 
        }

        // Shadow only on bottom and sides (not top)
        Rectangle {
            id: shadowSource
            anchors.fill: menuBox
            anchors.topMargin: 8
            anchors.margins: 4
            radius: 12
            color: "black"
            visible: false
        }
        
        DropShadow {
            anchors.fill: menuBox
            anchors.topMargin: 8
            source: shadowSource
            color: Qt.rgba(0, 0, 0, 0.3)
            radius: 16
            samples: 24
            verticalOffset: 2
            transparentBorder: true
        }

        // --- The Card ---
        Rectangle {
            id: menuBox
            width: parent.width
            height: column.implicitHeight + 16
            color: "transparent"
            radius: 0
            clip: true
            
            // Background with rounded bottom corners
            Rectangle {
                id: menuBackground
                anchors.fill: parent
                color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
                radius: 14
                
                // Cut off top to make it flat
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 14
                    color: parent.color
                }
            }
            
            // Border on sides and bottom only
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                border.color: root.colors.border
                radius: 14
                
                // Hide top border
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 2
                    color: Qt.rgba(root.colors.bg.r, root.colors.bg.g, root.colors.bg.b, 0.95)
                }
            }

            QsMenuOpener {
                id: opener
                menu: root.menuHandle
            }

            ColumnLayout {
                id: column
                anchors.fill: parent
                anchors.margins: 8
                spacing: 2

                Repeater {
                    model: opener.children

                    delegate: Item {
                        id: menuItem
                        
                        property bool isSeparator: modelData.isSeparator
                        property bool isHovered: hover.containsMouse && !isSeparator

                        Layout.fillWidth: true
                        Layout.preferredHeight: isSeparator ? 12 : 36

                        // Separator Line
                        Rectangle {
                            visible: isSeparator
                            anchors.centerIn: parent
                            width: parent.width - 16
                            height: 1
                            color: root.colors.border
                            opacity: 0.5
                        }

                        // Menu Item Background (Hover Pill)
                        Rectangle {
                            visible: !isSeparator
                            anchors.fill: parent
                            radius: 8
                            
                            color: isHovered ? root.colors.accent : "transparent"
                            opacity: isHovered ? 0.15 : 0
                            
                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            MouseArea {
                                id: hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: parent.isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                                onClicked: {
                                    if (!parent.isSeparator) {
                                        modelData.triggered();
                                        root.close();
                                    }
                                }
                            }
                        }
                        
                        // Active Indicator (Small accent pill on left)
                        Rectangle {
                            visible: !isSeparator && isHovered
                            width: 3
                            height: 16
                            radius: 2
                            color: root.colors.accent
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        // Content Row
                        RowLayout {
                            visible: !isSeparator
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            // Icon
                            Item {
                                Layout.preferredWidth: 20
                                Layout.preferredHeight: 20
                                
                                Image {
                                    anchors.centerIn: parent
                                    width: 16
                                    height: 16
                                    source: modelData.icon || ""
                                    fillMode: Image.PreserveAspectFit
                                    visible: modelData.icon !== undefined && modelData.icon !== ""
                                    
                                    layer.enabled: true
                                    layer.effect: ColorOverlay {
                                        color: isHovered ? root.colors.accent : root.colors.muted
                                    }
                                }
                                
                                // Fallback Icon
                                Text {
                                    anchors.centerIn: parent
                                    visible: !(modelData.icon !== undefined && modelData.icon !== "")
                                    text: "" // Circle
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 6
                                    color: isHovered ? root.colors.accent : root.colors.muted
                                }
                            }

                            // Text
                            Text {
                                text: modelData.text || ""
                                color: isHovered ? root.colors.fg : Qt.rgba(root.colors.fg.r, root.colors.fg.g, root.colors.fg.b, 0.8)
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 0.2
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            // Checkmark
                            Text {
                                visible: modelData.checkable && modelData.checked
                                text: ""
                                font.family: "Symbols Nerd Font"
                                color: root.colors.accent
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
        }
    }
}