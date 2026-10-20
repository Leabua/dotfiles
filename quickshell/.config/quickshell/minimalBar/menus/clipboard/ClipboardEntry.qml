import QtQuick
import qs.templates

Rectangle {
    id: entry

    property string title: ""
    property string detail: ""
    property bool selected: false
    signal hovered
    signal clicked

    implicitHeight: 54
    radius: 9
    color: Qt.alpha(Globals.fgColor, selected ? 0.11 : mouse.containsMouse ? 0.04 : 0)

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Text {
            width: parent.width
            text: entry.title
            textFormat: Text.PlainText
            color: Qt.alpha(Globals.fgColor, entry.selected ? 1 : 0.85)
            font.family: Globals.textFont.family
            font.pixelSize: 14
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: entry.detail
            textFormat: Text.PlainText
            color: Qt.alpha(Globals.fgColor, 0.46)
            font.family: Globals.textFont.family
            font.pixelSize: 12
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: entry.hovered()
        onClicked: entry.clicked()
    }
}
