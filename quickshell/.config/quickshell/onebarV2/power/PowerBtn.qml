import QtQuick
import qs.defaults

Item {
    id: root

    implicitHeight: textID.height
    implicitWidth: textID.implicitWidth

    BarIcon {
        id: textID
        text: "󰐥"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: Globals.powerMenuOpen = !Globals.powerMenuOpen
        }
    }
}
