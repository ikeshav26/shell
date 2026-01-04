import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
// Try standard module import first, but the relative import below ensures it works
import qs.Services 
import "../../../Services" as LocalServices

Item {
    id: root

    // --- Automatic Distro Fetcher ---
    // Uses the corrected service
    LocalServices.DistroInfoService {
        id: distroInfo
    }

    // --- Exposed Properties (Bound to Fetcher) ---
    property string distroName: distroInfo.name
    property string distroUrl: distroInfo.url
    property string distroIcon: distroInfo.icon
    
    property string distroBugUrl: distroInfo.bugUrl !== "" ? distroInfo.bugUrl : distroInfo.url
    property string distroSupportUrl: distroInfo.supportUrl !== "" ? distroInfo.supportUrl : distroInfo.url
    
    property string dotfilesName: "illogical-impulse"
    property string dotfilesUrl: "https://github.com/end-4/dots-hyprland"
    property string dotfilesIcon: "" 

    // --- Theme Specification ---
    property color backgroundColor: "#1e1e2e" // Dark Base
    property color cardColor: "#313244"       // Surface 1
    property color textPrimary: "#ffffff"     // White
    property color textSecondary: "#a6adc8"   // Muted Gray
    property color accentColor: "#89b4fa"     // Blue Accent
    property int cornerRadius: 16

    implicitWidth: 600
    implicitHeight: 800

    // --- Main Layout ---
    Rectangle {
        anchors.fill: parent
        color: root.backgroundColor

        ScrollView {
            anchors.fill: parent
            contentWidth: availableWidth
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 24
                
                // Outer Padding
                anchors.margins: 24
                anchors.topMargin: 24
                anchors.bottomMargin: 24
                
                // 1. Distro Section (Dynamic Data)
                AboutCard {
                    iconSource: root.distroIcon
                    titleText: root.distroName
                    linkUrl: root.distroUrl
                    
                    actions: [
                        { icon: "", label: "Website", url: root.distroUrl },
                        { icon: "", label: "Support", url: root.distroSupportUrl },
                        { icon: "", label: "Report Bug", url: root.distroBugUrl },
                        { icon: "", label: "Privacy", url: root.distroUrl }
                    ]
                }

                // 2. Dotfiles Section
                AboutCard {
                    iconSource: root.dotfilesIcon
                    titleText: root.dotfilesName
                    linkUrl: root.dotfilesUrl
                    
                    actions: [
                        { icon: "", label: "Docs", url: root.dotfilesUrl + "#readme" },
                        { icon: "", label: "Issues", url: root.dotfilesUrl + "/issues" },
                        { icon: "", label: "Discuss", url: root.dotfilesUrl + "/discussions" },
                        { icon: "", label: "Donate", url: "https://ko-fi.com/" }
                    ]
                }

                // 3. Contributors Section
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    Layout.topMargin: 8

                    Text {
                        text: "Core Developers"
                        font.pixelSize: 18
                        font.bold: true
                        color: root.textPrimary
                        Layout.leftMargin: 4
                    }

                    GridLayout {
                        columns: 2 
                        columnSpacing: 16
                        rowSpacing: 16
                        Layout.fillWidth: true

                        Repeater {
                            model: [
                                { name: "Manpreet Vilasara", url: "https://github.com/mannuvilasara" },
                                { name: "Keshav Gilhotra", url: "https://github.com/ikeshav26" }
                            ]

                            delegate: ContributorCard {
                                name: modelData.name
                                role: modelData.role
                                url: modelData.url
                                Layout.fillWidth: true
                            }
                        }
                    }
                }
                
                Item { height: 24; Layout.fillWidth: true }
            }
        }
    }

    // --- Reusable Components ---

    component AboutCard : Rectangle {
        id: cardRoot
        property string iconSource
        property string titleText
        property string linkUrl
        property var actions: []

        Layout.fillWidth: true
        implicitHeight: cardCol.implicitHeight + 48 
        color: root.cardColor
        radius: root.cornerRadius
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)

        ColumnLayout {
            id: cardCol
            anchors.fill: parent
            anchors.margins: 24
            spacing: 24

            RowLayout {
                spacing: 20
                Layout.fillWidth: true

                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 16
                    color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.1)
                    
                    Text {
                        anchors.centerIn: parent
                        text: cardRoot.iconSource
                        font.family: "Symbols Nerd Font"
                        font.pixelSize: 32
                        color: root.accentColor
                    }
                }

                ColumnLayout {
                    spacing: 4
                    Layout.fillWidth: true
                    
                    Text {
                        text: cardRoot.titleText
                        font.pixelSize: 24
                        font.bold: true
                        color: root.textPrimary
                    }
                    
                    Text {
                        text: cardRoot.linkUrl
                        font.pixelSize: 14
                        color: root.accentColor
                        font.underline: urlHover.containsMouse
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        
                        MouseArea {
                            id: urlHover
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: Qt.openUrlExternally(cardRoot.linkUrl)
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(1, 1, 1, 0.1)
            }

            Flow {
                Layout.fillWidth: true
                spacing: 12
                
                Repeater {
                    model: cardRoot.actions
                    delegate: Rectangle {
                        width: actionRow.implicitWidth + 32
                        height: 36
                        radius: 18 
                        color: actionHover.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                        border.width: 1
                        border.color: Qt.rgba(1, 1, 1, 0.1)
                        
                        MouseArea {
                            id: actionHover
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(modelData.url)
                        }

                        RowLayout {
                            id: actionRow
                            anchors.centerIn: parent
                            spacing: 8
                            Text { 
                                text: modelData.icon
                                font.family: "Symbols Nerd Font"
                                color: root.textSecondary 
                            }
                            Text { 
                                text: modelData.label
                                color: root.textPrimary 
                                font.weight: Font.Medium
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
        }
    }

    component ContributorCard : Rectangle {
        property string name
        property string role
        property string url
        
        implicitHeight: 80
        color: root.cardColor
        radius: 12
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.05)
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally(url)
            onEntered: parent.color = Qt.lighter(root.cardColor, 1.1)
            onExited: parent.color = root.cardColor
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            Rectangle {
                width: 48; height: 48
                radius: 24
                color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.2)
                
                Text {
                    anchors.centerIn: parent
                    text: name.charAt(0)
                    font.bold: true
                    font.pixelSize: 20
                    color: root.accentColor
                }
            }
            
            ColumnLayout {
                spacing: 2
                Text { 
                    text: name
                    font.bold: true
                    font.pixelSize: 16
                    color: root.textPrimary 
                }
                Text { 
                    text: role
                    font.pixelSize: 13
                    color: root.textSecondary 
                }
            }
        }
    }
}