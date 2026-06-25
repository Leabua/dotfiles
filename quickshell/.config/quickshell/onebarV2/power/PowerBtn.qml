import QtQuick
import qs.defaults

Item {
    id: root

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth

    Text {
        id: textID
        text: "󰐥 "
        color: Globals.fgColor
        font: Globals.textFont

        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: Globals.powerMenuOpen = !Globals.powerMenuOpen
        }
    }
}
