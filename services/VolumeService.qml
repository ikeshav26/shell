import QtQuick
import Quickshell.Io

Item {
    property int level: 0

    Process {
        id: volProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return
                var match = data.match(/Volume:\s*([\d.]+)/)
                if (match) {
                    level = Math.round(parseFloat(match[1]) * 100)
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: volProc.running = true
    }
}