import QtQuick
import QtQuick.Layouts
import qs.templates

Rectangle {
    id: filter

    property string label: ""
    property int count: 0
    property bool active: false
    signal clicked

    implicitWidth: content.implicitWidth + 20
    implicitHeight: 28
    radius: 7
    color: Qt.alpha(Globals.fgColor, active ? 0.12 : mouse.containsMouse ? 0.05 : 0)

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 7

        Text {
            text: filter.label
            color: Qt.alpha(Globals.fgColor, filter.active ? 1 : 0.65)
            font.family: Globals.textFont.family
            font.pixelSize: 13
            font.weight: filter.active ? Font.DemiBold : Font.Normal
        }

        Text {
            text: filter.count
            color: Qt.alpha(Globals.fgColor, filter.active ? 0.6 : 0.4)
            font.family: Globals.textFont.family
            font.pixelSize: 11
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: filter.clicked()
    }
}
