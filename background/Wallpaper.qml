import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io // Required for Process and StdioCollector
import "../core"

Item {
    id: root
    anchors.fill: parent

    // The path to the wallpaper
    property string source: "" 
    
    // Internal tracking for double-buffer logic
    property Image currentImage: img1

    onSourceChanged: {
        if (source === "") {
            currentImage = null
        } else {
            var nextImage = (currentImage === img1) ? img2 : img1
            nextImage.source = root.source
        }
    }

    IpcHandler {
        target: "wallpaper"
        function setWallpaper(path) {
            root.source = path
        }
    }

    // --- 1. The Process (KDialog / Dolphin Picker) ---
    Process {
        id: pickerProcess
        command: ["kdialog", "--title", "Select Wallpaper", "--getopenfilename", ".", "image/jpeg image/png image/webp image/svg+xml"]
        
        // CORRECTED: Use StdioCollector to capture output
        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                if (output !== "") {
                    root.source = "file://" + output
                }
            }
        }
    }

    // --- 2. Placeholder UI ---
    Rectangle {
        anchors.fill: parent
        color: "#1e1e2e"
        visible: root.source === ""
        z: 10 

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "☹"
                font.pixelSize: 64
                color: "#f38ba8" 
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Wallpaper missing?"
                color: "#cdd6f4"
                font.bold: true
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }

            // The Button
            Rectangle {
                Layout.preferredWidth: 200
                Layout.preferredHeight: 40
                radius: 20
                color: mouseArea.pressed ? "#cba6f7" : "#313244"
                
                Text {
                    anchors.centerIn: parent
                    text: "Select via Dolphin"
                    color: "#cdd6f4"
                    font.bold: true
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    
                    // Run the process
                    onClicked: pickerProcess.running = true
                }

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    // --- 3. Double Buffered Images ---
    Image {
        id: img1
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: (root.currentImage === img1) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }
        onStatusChanged: if (status === Image.Ready && root.currentImage !== img1 && source == root.source) root.currentImage = img1
    }

    Image {
        id: img2
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: (root.currentImage === img2) ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }
        onStatusChanged: if (status === Image.Ready && root.currentImage !== img2 && source == root.source) root.currentImage = img2
    }
}