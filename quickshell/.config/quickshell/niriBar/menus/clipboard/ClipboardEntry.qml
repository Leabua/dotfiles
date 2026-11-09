import QtQuick
import qs.templates

Rectangle {
    id: entry

    property string title: ""
    property string detail: ""
    property bool selected: false
    property bool marked: false
    signal hovered
    signal clicked(int modifiers)

    implicitHeight: 54
    radius: 9
    color: Qt.alpha(Globals.fgColor, selected ? 0.11 : marked ? 0.07 : mouse.containsMouse ? 0.04 : 0)
    border.width: marked ? 1 : 0
    border.color: Qt.alpha(Globals.fgColor, 0.18)

    Column {
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: markBadge.visible ? markBadge.left : parent.right
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

    // shown while the entry is part of a multi-selection
    Rectangle {
        id: markBadge
        visible: entry.marked
        width: 20
        height: 20
        radius: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        color: Globals.fgColor

        MenuIcon {
            anchors.centerIn: parent
            width: 14
            height: 14
            name: "check"
            strokeWidth: 2.4
            color: Globals.bgColor
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: entry.hovered()
        onClicked: event => entry.clicked(event.modifiers)
    }
}
