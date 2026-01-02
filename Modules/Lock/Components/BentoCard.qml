import QtQuick

Rectangle {
    id: root

    property color cardColor: "transparent"
    property color borderColor: "gray"

    color: Qt.rgba(cardColor.r, cardColor.g, cardColor.b, 0.45)
    radius: 16
    border.width: 1
    border.color: borderColor
}
