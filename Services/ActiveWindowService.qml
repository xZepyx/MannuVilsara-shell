import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

Item {
    property string title: ""

    Process {
        id: windowProc

        // Fetch active window AND focused workspace ID from hyprctl for consistency
        // Uses jq to parse both sources and combine them into one JSON object
        command: ["sh", "-c", "hyprctl activewindow -j | jq -c --argjson activeWs $(hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id') '{win: ., activeWs: $activeWs}'"]

        stdout: SplitParser {
            onRead: (data) => {
                if (!data || !data.trim()) return;
                
                try {
                    const parsed = JSON.parse(data.trim());
                    const win = parsed.win;
                    const activeWs = parsed.activeWs;

                    // 1. Check valid window
                    // 2. Compare window workspace with currently focused workspace
                    if (win && win.workspace && activeWs && win.workspace.id === activeWs) {
                        title = win.title || "~";
                    } else {
                        title = "~";
                    }
                } catch (e) {
                    console.warn("Failed to parse active window data:", e);
                    title = "";
                }
            }
        }
    }

    // Poll every 200ms to keep title updated
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }
}