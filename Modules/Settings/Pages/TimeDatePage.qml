import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services
import qs.Widgets

ColumnLayout {
    property var context
    property var colors: context.colors

    spacing: 16

    Text {
        text: "Time & Date"
        font.family: Config.fontFamily
        font.pixelSize: 20
        font.bold: true
        color: colors.fg
    }

    ToggleButton {
        Layout.fillWidth: true
        label: "24-Hour Format"
        sublabel: "Use 24-hour time format instead of 12-hour"
        icon: "󰖲"
        active: Config.use24HourFormat
        colors: context.colors
        onActiveChanged: {
            if (Config.use24HourFormat !== active)
                Config.use24HourFormat = active;
        }
    }
}