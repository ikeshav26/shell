import QtQuick
import Quickshell.Io
import Quickshell.Hyprland

Item {
    property string layout: "Tile"

    Process {
        id: layoutProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r 'if .floating then \"Floating\" elif .fullscreen == 1 then \"Fullscreen\" else \"Tiled\" end'"]
        stdout: SplitParser {
            onRead: data => {
                if (data && data.trim()) {
                    layout = data.trim()
                }
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            layoutProc.running = true
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: layoutProc.running = true
    }
}