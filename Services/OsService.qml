import QtQuick
import Quickshell.Io

Item {
    property string version: "Linux"

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: SplitParser {
            onRead: data => {
                if (data) version = data.trim()
            }
        }
        Component.onCompleted: running = true
    }
}