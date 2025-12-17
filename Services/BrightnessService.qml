pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property real brightness: 0.0

    function setBrightness(v) {
        // v is 0.0 - 1.0
        // brightnessctl expects %, e.g. 50%
        var percent = Math.round(v * 100)
        setProc.command = ["brightnessctl", "s", percent + "%"]
        setProc.running = true
        // Optimistic update
        brightness = v
    }

    Process {
        id: setProc
    }

    Process {
        id: brightProc
        command: ["brightnessctl", "-m"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                // data is like "nvidia_0,backlight,100,100%,100" (or similar variations)
                var parts = data.split(",")
                for (var i = 0; i < parts.length; i++) {
                    if (parts[i].endsWith("%")) {
                        var val = parseFloat(parts[i])
                        brightness = val / 100.0
                        return
                    }
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightProc.running = true
    }
}
