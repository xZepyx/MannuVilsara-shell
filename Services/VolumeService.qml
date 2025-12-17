pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property real volume: 0.0

    function setVolume(v) {
        // v is 0.0 - 1.0
        // wpctl expects %, e.g. 50%
        var percent = Math.round(v * 100)
        setProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", percent + "%"]
        setProc.running = true
        // Optimistic update
        volume = v
    }

    Process {
        id: setProc
    }

    Process {
        id: volProc
        // Use sh and awk to extract just the number, handling [MUTED] suffix automatically by taking the second column
        // Output of wpctl: "Volume: 0.45" or "Volume: 0.45 [MUTED]"
        // awk '{print $2}' gives "0.45"
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var val = parseFloat(data.trim())
                if (!isNaN(val)) {
                    volume = val
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: volProc.running = true
    }
}