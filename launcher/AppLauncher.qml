import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../core"

PanelWindow {
    id: root

    required property Colors colors
    // --- Window Configuration ---
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: false

    // --- Logic ---
    Shortcut { sequence: "Escape"; onActivated: root.visible = false }
    MouseArea { anchors.fill: parent; z: -1; onClicked: root.visible = false }

    onVisibleChanged: {
        if (visible) {
            query = ""
            input.text = ""
            input.forceActiveFocus()
            appList.currentIndex = 0
        }
    }

    property string query: ""
    property var filteredApps: {
        var apps = DesktopEntries.applications.values;
        return apps.filter(app => {
            if (app.noDisplay) return false;
            if (query === "") return false;
            return app.name.toLowerCase().includes(query.toLowerCase());
        });
    }

    // --- MAIN CONTAINER ---
    Rectangle {
        id: mainContainer
        width: 480 // Compact Width
        anchors.centerIn: parent

        // Height: Header (60) + List (Dynamic)
        height: 60 + (appList.count > 0 ? Math.min(appList.count * 44, 350) : 0)

        // STYLE: Tokyo Night Matte
        color: colors.bg
        border.color: colors.muted
        border.width: 1
        radius: 12
        clip: true

        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutQuart } }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // --- SEARCH HEADER ---
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text { 
                        text: "🔎"
                        font.pixelSize: 18
                        color: colors.purple 
                    }

                    TextField {
                        id: input
                        Layout.fillWidth: true
                        background: null
                        color: colors.fg
                        font.pixelSize: 18
                        font.bold: true
                        placeholderText: "Search..."
                        placeholderTextColor: colors.muted
                        verticalAlignment: TextInput.AlignVCenter

                        onTextChanged: { root.query = text; appList.currentIndex = 0 }
                        Keys.onDownPressed: appList.incrementCurrentIndex()
                        Keys.onUpPressed: appList.decrementCurrentIndex()
                        Keys.onReturnPressed: if (appList.count > 0) { appList.model[appList.currentIndex].execute(); root.visible = false }
                    }
                }

                // Separator Line
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: colors.muted
                    visible: appList.count > 0
                    opacity: 0.5
                }
            }

            // --- RESULTS LIST ---
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                visible: count > 0
                model: root.filteredApps
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    width: appList.width
                    height: 44 // Compact Row
                    color: "transparent"

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: appList.currentIndex = index
                        onClicked: { modelData.execute(); root.visible = false }
                    }

                    // --- SELECTION BACKGROUND ---
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 4
                        radius: 6
                        // Muted background when selected (low opacity)
                        color: ListView.isCurrentItem ? Qt.rgba(colors.muted.r, colors.muted.g, colors.muted.b, 0.3) : "transparent"
                        
                        // --- THE FRONT BAR (Accent) ---
                        Rectangle {
                            width: 3
                            height: 20 // Taller bar for visibility
                            radius: 2
                            // Uses Cyan to POP against the purple text
                            color: colors.cyan 
                            
                            anchors.left: parent.left
                            anchors.leftMargin: 6
                            anchors.verticalCenter: parent.verticalCenter
                            
                            // Only visible when selected
                            visible: parent.parent.ListView.isCurrentItem
                        }
                    }

                    // --- CONTENT ---
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 20 // Space for the accent bar
                        anchors.rightMargin: 16
                        spacing: 12

                        Image {
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                            fillMode: Image.PreserveAspectFit
                            source: {
                                if (modelData.icon.indexOf("/") !== -1) return "file://" + modelData.icon
                                return "image://icon/" + modelData.icon
                            }
                        }

                        Text {
                            text: modelData.name
                            // Selected: Purple | Unselected: Foreground (White-ish)
                            color: ListView.isCurrentItem ? colors.purple : colors.fg
                            
                            font.bold: true
                            font.pixelSize: 14
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }

                        Text {
                            text: "↵"
                            color: colors.muted
                            font.pixelSize: 14
                            visible: ListView.isCurrentItem
                        }
                    }
                }
            }
        }
    }
}