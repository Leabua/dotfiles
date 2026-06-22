import QtQuick
import qs

Item {
    id: root

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth

    Text {
        id: textID
        text: "󰐥 "
        color: Globals.fgColor
        font: Globals.textFont
    }
}
