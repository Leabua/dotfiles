import QtQuick
import QtQuick.Layouts
import qs.templates

RowLayout {
    id: root
    property string icon: ""
    property string displayText: ""
    property color color: Globals.fgColor
    spacing: Globals.spacing / 3

    Text {
        id: iconID
        text: root.icon
        font.family: Globals.textFont.family
        font.weight: Globals.textFont.weight
        font.pixelSize: Globals.barIconSize
        color: root.color
        visible: text !== ""
    }

    Text {
        id: textID
        text: root.displayText
        font: Globals.textFont
        color: root.color
        visible: text !== ""
    }
}
