import QtQuick
import qs.templates

Item {
    id: root

    readonly property string icon: Globals.caffeinated ? String.fromCodePoint(0xF0176) : String.fromCodePoint(0xF0FAB)
    readonly property color displayColor: Globals.caffeinated ? Globals.healthy : Globals.fgColor

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    BarIcon {
        id: content
        icon: root.icon
        color: root.displayColor
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.toggleCaffeine()
    }
}
