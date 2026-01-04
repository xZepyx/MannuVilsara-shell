import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import Quickshell.Io

BentoCard {
    id: root

    required property var colors

    cardColor: colors.surface
    borderColor: colors.border

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Item {
            Layout.preferredWidth: 100
            Layout.preferredHeight: 100
            Layout.alignment: Qt.AlignHCenter

            Image {
                anchors.fill: parent
                source: "file:///home/" + Quickshell.env("USER") + "/.face"
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 100
                        height: 100
                        radius: 50
                    }
                }
                
                // Fallback if no user icon
                onStatusChanged: {
                    if (status === Image.Error) {
                        if (source.toString().endsWith("/.face")) {
                            source = "file:///home/" + Quickshell.env("USER") + "/.face.icon"
                        } else if (source.toString().endsWith("/.face.icon")) {
                            source = "/var/lib/AccountsService/icons/" + Quickshell.env("USER")
                        } else {
                            source = "../../Assets/logo.svg" 
                        }
                    }
                }
            }
        }

        Text {
            text: Quickshell.env("USER")
            font.pixelSize: 20
            font.bold: true
            color: root.colors.fg
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "@" + hostnameProc.hostname
            font.pixelSize: 16
            color: root.colors.muted
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Process {
        id: hostnameProc
        property string hostname: "localhost"
        command: ["cat", "/etc/hostname"]
        running: true
        stdout: SplitParser {
            onRead: (data) => hostnameProc.hostname = data.trim()
        }
    }
}
