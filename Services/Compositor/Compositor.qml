import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Item {
    id: root

    property string title: loader.item ? loader.item.title : ""
    property bool isFullscreen: loader.item ? loader.item.isFullscreen : false
    property string layout: loader.item ? loader.item.layout : "Tiled"
    property int activeWorkspace: loader.item ? loader.item.activeWorkspace : 1
    property var workspaces: loader.item ? loader.item.workspaces : []
    property bool isSpecialOpen: (detectedCompositor === "hyprland") && loader.item ? loader.item.isSpecialOpen : false
    property string detectedCompositor: "hyprland"

    function changeWorkspace(id) {
        if (loader.item)
            loader.item.changeWorkspace(id);

    }

    function changeWorkspaceRelative(delta) {
        if (loader.item)
            loader.item.changeWorkspaceRelative(delta);

    }

    Process {
        id: detectProc

        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        running: true

        stdout: SplitParser {
            onRead: (data) => {
                if (!data)
                    return ;

                const val = data.trim().toLowerCase();
                if (val.includes("niri")) {
                    root.detectedCompositor = "niri";
                    loader.sourceComponent = niriComponent;
                } else if (val.includes("hyprland")) {
                    root.detectedCompositor = "hyprland";
                    loader.sourceComponent = hyprlandComponent;
                }
            }
        }

    }

    Loader {
        id: loader
    }

    Component {
        id: hyprlandComponent

        Item {
            property string title: ""
            property bool isFullscreen: false
            property string layout: "Tiled"
            property int activeWorkspace: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
            property var workspaces: Hyprland.workspaces.values
            property bool isSpecialOpen: Hyprland.focusedMonitor && Hyprland.focusedMonitor.lastIpcObject.specialWorkspace.name !== ""

            function changeWorkspace(id) {
                Hyprland.dispatch("workspace " + id);
            }

            function changeWorkspaceRelative(delta) {
                let cmd = delta > 0 ? "workspace +1" : "workspace -1";
                Hyprland.dispatch(cmd);
            }

            Connections {
                function onRawEvent(event) {
                    const n = event.name;
                    if (["activespecial", "focusedmon", "workspace", "moveworkspace", "createworkspace", "destroyworkspace"].includes(n))
                        Hyprland.refreshMonitors();

                }

                target: Hyprland
            }

            Process {
                id: windowProc

                command: ["sh", "-c", "hyprctl activewindow -j | jq -c --argjson activeWs $(hyprctl monitors -j | jq '.[] | select(.focused) | .activeWorkspace.id') '{win: ., activeWs: $activeWs}'"]

                stdout: SplitParser {
                    onRead: (data) => {
                        if (!data || !data.trim())
                            return ;

                        try {
                            const parsed = JSON.parse(data.trim());
                            const win = parsed.win;
                            const activeWs = parsed.activeWs;
                            if (win && win.workspace && activeWs && win.workspace.id === activeWs) {
                                title = win.title || "~";
                                isFullscreen = (win.fullscreen > 0);
                                if (win.floating)
                                    layout = "Floating";
                                else if (win.fullscreen > 0)
                                    layout = "Fullscreen";
                                else
                                    layout = "Tiled";
                            } else {
                                title = "~";
                                isFullscreen = false;
                                layout = "Tiled";
                            }
                        } catch (e) {
                            console.warn("Failed to parse active window data:", e);
                            title = "";
                            isFullscreen = false;
                            layout = "Tiled";
                        }
                    }
                }

            }

            Timer {
                interval: 200
                running: true
                repeat: true
                onTriggered: windowProc.running = true
            }

        }

    }

    Component {
        id: niriComponent

        Item {
            id: niriItem

            property string title: ""
            property bool isFullscreen: false
            property string layout: "Tiled"
            property int activeWorkspace: 1
            property var workspaces: []
            property var workspaceCache: ({
            })
            property bool initialized: false

            function changeWorkspace(id) {
                sendSocketCommand(niriCommandSocket, {
                    "Action": {
                        "focus_workspace": {
                            "reference": {
                                "Id": id
                            }
                        }
                    }
                });
                dispatchProc.command = ["niri", "msg", "action", "focus-workspace", id.toString()];
                dispatchProc.running = true;
            }

            function changeWorkspaceRelative(delta) {
                const cmd = delta > 0 ? "focus-workspace-down" : "focus-workspace-up";
                dispatchProc.command = ["niri", "msg", "action", cmd];
                dispatchProc.running = true;
            }

            function sendSocketCommand(sock, command) {
                if (sock.connected)
                    sock.write(JSON.stringify(command) + "\n");

            }

            function startEventStream() {
                sendSocketCommand(niriEventStream, "EventStream");
            }

            function updateWorkspaces() {
                sendSocketCommand(niriCommandSocket, "Workspaces");
            }

            function updateWindows() {
                sendSocketCommand(niriCommandSocket, "Windows");
            }

            function updateFocusedWindow() {
                sendSocketCommand(niriCommandSocket, "FocusedWindow");
            }

            function recollectWorkspaces(workspacesData) {
                const workspacesList = [];
                workspaceCache = {
                };
                for (const ws of workspacesData) {
                    // Mannu uses 1-based index usually
                    // Keep internal ID

                    const wsData = {
                        "id": (ws.idx !== undefined ? ws.idx + 1 : ws.id),
                        "internalId": ws.id,
                        "idx": ws.idx,
                        "name": ws.name || "",
                        "output": ws.output || "",
                        "isFocused": ws.is_focused === true,
                        "isActive": ws.is_active === true
                    };
                    workspacesList.push(wsData);
                    workspaceCache[ws.id] = wsData;
                    if (wsData.isFocused)
                        activeWorkspace = wsData.id;

                }
                workspacesList.sort((a, b) => {
                    return a.id - b.id;
                });
                workspaces = workspacesList;
            }

            function recollectFocusedWindow(win) {
                if (win && win.title) {
                    title = win.title || "~";
                    isFullscreen = win.is_fullscreen || false;
                    layout = "Tiled"; // Niri is tiled mostly
                } else {
                    title = "~";
                    isFullscreen = false;
                    layout = "Tiled";
                }
            }

            Component.onCompleted: {
                if (Quickshell.env("NIRI_SOCKET")) {
                    niriCommandSocket.connected = true;
                    niriEventStream.connected = true;
                    initialized = true;
                }
            }

            Socket {
                id: niriCommandSocket

                path: Quickshell.env("NIRI_SOCKET") || ""
                connected: false
                onConnectedChanged: {
                    if (connected) {
                        updateWorkspaces();
                        updateFocusedWindow();
                    }
                }

                parser: SplitParser {
                    onRead: function(line) {
                        if (!line.trim())
                            return ;

                        try {
                            const data = JSON.parse(line);
                            if (data && data.Ok) {
                                const res = data.Ok;
                                if (res.Workspaces)
                                    recollectWorkspaces(res.Workspaces);
                                else if (res.FocusedWindow)
                                    recollectFocusedWindow(res.FocusedWindow);
                            }
                        } catch (e) {
                            console.warn("Niri socket parse error:", e);
                        }
                    }
                }

            }

            Socket {
                id: niriEventStream

                path: Quickshell.env("NIRI_SOCKET") || ""
                connected: false
                onConnectedChanged: {
                    if (connected)
                        startEventStream();

                }

                parser: SplitParser {
                    onRead: (data) => {
                        if (!data.trim())
                            return ;

                        try {
                            const event = JSON.parse(data.trim());
                            if (event.WorkspacesChanged)
                                recollectWorkspaces(event.WorkspacesChanged.workspaces);
                            else if (event.WorkspaceActivated)
                                updateWorkspaces(); // Re-fetch to be safe and get full state
                            else if (event.WindowFocusChanged)
                                updateFocusedWindow();
                            else if (event.WindowOpenedOrChanged)
                                updateFocusedWindow(); // Check if new window is focused
                            else if (event.WindowClosed)
                                updateFocusedWindow();
                        } catch (e) {
                            console.warn("Niri event stream parse error:", e);
                        }
                    }
                }

            }

            Process {
                id: dispatchProc
            }

        }

    }

}
