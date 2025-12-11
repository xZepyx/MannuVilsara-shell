import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Rectangle {
    property string label: ""
    property string icon: ""
    property real value: 0.5

    // Theme properties that need to be passed from parent
    property var theme

    Layout.fillWidth: true
    implicitHeight: theme ? theme.sliderHeight : 64
    color: theme ? theme.tile : "#2F333D"
    radius: 12

    // Full-area MouseArea for wheel events and left-click positioning (overlay)
    MouseArea {
        anchors.fill: parent
        z: 1 // Above content but below any interactive elements

        onWheel: function(wheel) {
            // Adjust value based on scroll direction
            // Use a step size of 0.05 (5%) per scroll
            var step = 0.05
            if (wheel.angleDelta.y > 0) {
                // Scroll up - increase value
                value = Math.min(1, value + step)
            } else {
                // Scroll down - decrease value
                value = Math.max(0, value - step)
            }
        }

        onClicked: function(mouse) {
            // Set value based on click position across the entire width
            value = Math.max(0, Math.min(1, mouse.x / width))
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true

            MouseArea {
                Layout.fillWidth: true
                Layout.fillHeight: true
                cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        value = Math.max(0, Math.min(1, mouse.x / width))
                    }
                }

                onPressed: function(mouse) {
                    value = Math.max(0, Math.min(1, mouse.x / width))
                }

                // Pass through to content
                RowLayout {
                    anchors.fill: parent
                    spacing: 10

                    Text {
                        text: icon
                        font.pixelSize: theme ? theme.sliderIconSize : 20
                        font.family: "Symbols Nerd Font"
                        color: theme ? theme.text : "#E8EAF0"
                    }

                    Text {
                        text: label
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: theme ? theme.text : "#E8EAF0"
                        Layout.fillWidth: true
                    }

                    Text {
                        text: Math.round(value * 100) + "%"
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        color: theme ? theme.secondary : "#9BA3B8"
                    }
                }
            }
        }

        // Slider Track
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            radius: 3
            color: theme ? theme.sliderTrack : "#3A3F4B"

            Rectangle {
                height: parent.height
                width: parent.width * value
                radius: 3
                color: theme ? theme.sliderFill : "#CBA6F7"

                Behavior on width {
                    NumberAnimation {
                        duration: 150
                        easing.type: Easing.OutQuad
                    }
                }

                // Thumb
                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: theme ? theme.sliderThumb : "#FFFFFF"
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        horizontalOffset: 0
                        verticalOffset: 2
                        radius: 8
                        samples: 17
                        color: Qt.rgba(0, 0, 0, 0.2)
                    }
                }
            }

            MouseArea {
                anchors.fill: parent

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        value = Math.max(0, Math.min(1, mouse.x / width))
                    }
                }

                onPressed: function(mouse) {
                    value = Math.max(0, Math.min(1, mouse.x / width))
                }
            }
        }
    }
}