import QtQuick
import Quickshell
import Quickshell.Io
import qs.Core
pragma Singleton

Singleton {
    id: root

    property string configPath: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/mannu/config.json"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14
    property string wallpaperDirectory: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property bool disableHover: false
    property bool floatingBar: false
    property var colors: null
    property var openRgbDevices: [0]
    property bool debug: false

    onDebugChanged: Logger.debugEnabled = debug
    Component.onCompleted: Logger.debugEnabled = debug

    FileView {
        id: configFile

        path: root.configPath
        watchChanges: true
        onFileChanged: {
            Logger.d("Config", "Config changed, reloading...");
            configFile.reload();
        }
        onLoaded: {
            try {
                var json = JSON.parse(configFile.text());
                if (json.fontFamily)
                    root.fontFamily = json.fontFamily;

                if (json.fontSize)
                    root.fontSize = json.fontSize;

                if (json.wallpaperDirectory)
                    root.wallpaperDirectory = json.wallpaperDirectory;

                if (json.disableHover !== undefined)
                    root.disableHover = json.disableHover;

                if (json.floatingBar !== undefined) {
                    root.floatingBar = json.floatingBar;
                    Logger.d("Config", "floatingBar set to", root.floatingBar);
                }
                if (json.colors)
                    root.colors = json.colors;

                if (json.debug !== undefined)
                    root.debug = json.debug;

                if (json.openRgbDevices !== undefined) {
                    if (Array.isArray(json.openRgbDevices))
                        root.openRgbDevices = json.openRgbDevices;
                    else if (typeof json.openRgbDevices === 'number')
                        root.openRgbDevices = [json.openRgbDevices];
                    Logger.d("Config", "openRgbDevices set to", JSON.stringify(root.openRgbDevices));
                }
                Logger.i("Config", "Loaded from " + root.configPath);
            } catch (e) {
                Logger.e("Config", "Failed to parse config: " + e);
            }
        }
    }

}
