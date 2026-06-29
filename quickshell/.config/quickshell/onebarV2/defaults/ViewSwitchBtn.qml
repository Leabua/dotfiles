import qs.defaults
import QtQuick
import QtQuick.Layouts

// Compact horizontal [icon + label] button 
Rectangle {
    id: root

    property string icon
    property string label
    signal clicked

    implicitWidth: content.implicitWidth + Globals.padding
    implicitHeight: content.implicitHeight + Globals.spacing
    radius: Globals.radius
    color: ma.containsMouse ? Globals.fgColor : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Globals.animFast
        }
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: Globals.spacing

        Text {
            text: root.icon
            visible: Globals.buttonIcons
            color: ma.containsMouse ? Globals.bgColor : Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 2
            font.weight: Globals.textFont.weight
        }
        Text {
            text: root.label
            visible: root.label !== ""
            color: ma.containsMouse ? Globals.bgColor : Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 1
            font.weight: Globals.textFont.weight - 100
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
