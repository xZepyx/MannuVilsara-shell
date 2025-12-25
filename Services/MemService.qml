import QtQuick
import Quickshell.Io

Item {
    // Expose total and used (bytes) plus usage percent
    property int total: 0
    property int used: 0
    property int usage: 0
    
    // Temporary storage for output
    property string outputBuffer: ""

    Process {
        id: memProc

        // Use free with bytes and parse Mem line
        command: ["sh", "-c", "free -b | grep '^Mem:' | awk '{print $2, $3}'"]

        // Capture stdout as it comes in
        stdout: SplitParser {
            onRead: (data) => {
                console.log("[MemService] stdout received:", JSON.stringify(data));
                
                if (!data) {
                    console.log("[MemService] No data received");
                    return;
                }
                
                var output = data.trim();
                console.log("[MemService] Trimmed output:", JSON.stringify(output));
                
                if (output === "") {
                    console.log("[MemService] Empty output after trim");
                    return;
                }
                
                // Split by whitespace
                var parts = output.split(/\s+/);
                console.log("[MemService] Split into", parts.length, "parts:", JSON.stringify(parts));
                
                if (parts.length < 2) {
                    console.log("[MemService] Not enough parts");
                    return;
                }
                
                var totalBytes = parseInt(parts[0]);
                var usedBytes = parseInt(parts[1]);
                
                console.log("[MemService] Parsed - totalBytes:", totalBytes, "usedBytes:", usedBytes);
                
                if (isNaN(totalBytes) || isNaN(usedBytes) || totalBytes <= 0) {
                    console.log("[MemService] Invalid values");
                    return;
                }
                
                // Update properties
                total = totalBytes;
                used = usedBytes;
                usage = Math.round((usedBytes / totalBytes) * 100);
                
                console.log("[MemService] SUCCESS - Total:", (total/1073741824).toFixed(2), "GB, Used:", (used/1073741824).toFixed(2), "GB, Usage:", usage + "%");
            }
        }

        onExited: (code) => {
            console.log("[MemService] Process exited with code:", code);
        }

        onStarted: {
            console.log("[MemService] Process started");
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            console.log("[MemService] Timer tick - triggering memory check");
            memProc.running = true;
        }
    }

    Component.onCompleted: {
        console.log("[MemService] Component initialized");
    }
}