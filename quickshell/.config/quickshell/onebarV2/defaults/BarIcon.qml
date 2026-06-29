import QtQuick
import QtQuick.Layouts
import qs.defaults

Text {
    color: Globals.fgColor
    font.family: Globals.textFont.family
    font.pixelSize: Globals.barIconSize
    font.weight: Globals.textFont.weight
    verticalAlignment: Text.AlignVCenter
    height: fm.height                 // standalone use (single Text in an Item)
    Layout.preferredHeight: fm.height // inside a RowLayout

    FontMetrics {
        id: fm
        font: Globals.textFont
    }
}
