import QtQuick
import Quickshell

Rectangle {
    id: root
    signal clicked()
    property string label: ""
    property bool filled: false

    implicitWidth: labelText.implicitWidth + 24
    implicitHeight: 28
    radius: 14
    color: filled ? global.fgColor : "transparent"
    border.color: filled ? "transparent" : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.35)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        id: labelText
        anchors.centerIn: parent
        text: root.label
        font.family: global.shellFont.family
        font.pixelSize: 13
        font.bold: true
        color: filled ? global.bgColor : global.fgColor
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: global.fgColor
        opacity: hover.hovered && !filled ? 0.08 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    
    TapHandler { onTapped: root.clicked() }
}
