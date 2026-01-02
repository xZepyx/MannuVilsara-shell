import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

SettingItem {
    id: root

    // Properties for backward compatibility
    property bool active: false

    // Switch component in the content area
    ToggleSwitch {
        checked: root.active
        colors: root.colors
        onCheckedChanged: {
            if (root.active !== checked)
                root.active = checked;

        }
    }

}
