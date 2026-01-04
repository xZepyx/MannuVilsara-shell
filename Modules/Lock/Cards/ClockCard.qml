import "../Components"
import QtQuick
import QtQuick.Layouts

BentoCard {
    id: root

    required property var colors
    property int hours: new Date().getHours()
    property int minutes: new Date().getMinutes()
    property int seconds: new Date().getSeconds()

    cardColor: colors.surface
    borderColor: colors.border

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date();
            root.hours = now.getHours();
            root.minutes = now.getMinutes();
            root.seconds = now.getSeconds();
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            text: root.hours.toString().padStart(2, '0') + ":" + root.minutes.toString().padStart(2, '0')
            font.pixelSize: 48
            font.weight: Font.Bold
            font.family: "JetBrainsMono Nerd Font"
            color: root.colors.fg
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: Qt.formatDate(new Date(), "dd/MM/yy")
            font.pixelSize: 16
            color: root.colors.muted
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
