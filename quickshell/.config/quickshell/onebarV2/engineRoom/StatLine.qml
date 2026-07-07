import QtQuick
import QtQuick.Layouts
import qs.defaults

// One btop-style stat row: dim key on the left, value hugging the right edge.
RowLayout {
    id: root

    property string key: ""
    property string val: ""
    property color valColor: Globals.fgColor

    Layout.fillWidth: true
    spacing: Globals.spacing

    Text {
        text: root.key
        color: Qt.alpha(Globals.fgColor, 0.55)
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize - 3
        font.weight: Globals.textFont.weight
    }
    Item {
        Layout.fillWidth: true
    }
    Text {
        text: root.val
        color: root.valColor
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize - 3
        font.weight: Globals.textFont.weight
    }
}
