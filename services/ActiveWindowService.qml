import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Item {
    property string title: "Window"

    Process {
        id: windowProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    title = data.trim()
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            windowProc.running = true
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: windowProc.running = true
    }
}