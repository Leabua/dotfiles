import QtQuick
import QtQuick.Layouts
import qs.templates

Item {
    id: root
    property string icon
    property string displayText

    RowLayout {
        id: row

        Text {
            text: root.icon
            font: Globals.textFont
            color: Globals.fgColor
        }

        Text {
            text: root.displayText
            font: Globals.textFont
            color: Globals.fgColor
        }
    }
}
