import QtQuick
import QtQuick.Layouts
import qs.templates

// A quiet label with its reading aligned to the section's right edge.
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
        font.pixelSize: 12
        font.weight: Font.Normal
    }
    Item {
        Layout.fillWidth: true
    }
    Text {
        text: root.val
        color: root.valColor
        font.family: Globals.textFont.family
        font.pixelSize: 12
        font.weight: Font.Medium
    }
}
