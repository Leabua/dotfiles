import QtQuick
import QtQuick.Layouts
import qs.templates

Rectangle {
    id: row

    property string text: ""
    property string icon: ""
    property bool active: false
    property bool selected: false
    property bool destructive: false
    signal clicked
    signal hovered

    Layout.fillWidth: true
    implicitHeight: 44
    radius: 9
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.35
    color: Qt.alpha(Globals.fgColor, selected || activeFocus ? 0.11 : active ? 0.08 : mouse.containsMouse ? 0.04 : 0)
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()
    scale: mouse.pressed ? 0.985 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 12
        spacing: 10

        MenuIcon {
            visible: Globals.buttonIcons && row.icon !== ""
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            name: row.icon
            color: row.destructive && mouse.containsMouse ? Globals.criticalColor : Qt.alpha(Globals.fgColor, 0.7)
        }

        Text {
            Layout.fillWidth: true
            text: row.text
            color: row.destructive && mouse.containsMouse ? Globals.criticalColor : Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: 14
            font.weight: Font.Medium
            elide: Text.ElideRight
        }

        MenuIcon {
            visible: row.active
            name: "check"
            color: Qt.alpha(Globals.fgColor, 0.8)
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: row.hovered()
        onClicked: row.clicked()
    }
}
