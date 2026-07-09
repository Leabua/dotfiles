import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string icon
    property string displayText

    RowLayout {
        id: row

        Text {
            text: root.icon
            font.family: Globals.textFont.family
            font.weight: Globals.textFont.weight
            font.pixelSize: Globals.barIconSize
            color: Globals.fgColor
        }

        Text {
            text: root.displayText
            font: Globals.textFont
            color: Globals.fgColor
        }
    }
}
