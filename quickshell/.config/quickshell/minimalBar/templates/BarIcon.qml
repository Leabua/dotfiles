import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    property string icon: ""
    property string displayText: ""
    property color color: Globals.fgColor
    spacing: Globals.spacing

    implicitHeight: Math.max(displayText.implicitHeight, icon.implicitHeight)
    implicitWidth: Math.max(displayText.implicitWidth, icon.implicitWidth)

    Text {
        id: icon
        text: root.icon
        font.family: Globals.textFont.family
        font.weight: Globals.textFont.weight
        font.pixelSize: Globals.barIconSize
        color: root.color
        visible: text !== ""
    }

    Text {
        id: displayText
        text: root.displayText
        font: Globals.textFont
        color: root.color
        visible: text !== ""
    }
}
