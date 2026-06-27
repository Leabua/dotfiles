import QtQuick
import QtQuick.Layouts
import qs.defaults

// A bar status glyph vertically centred on the text line. Nerd-font icons sit low
// in their line box, so we render the glyph in a box the height of the value text
// and AlignVCenter it -> the icon shares a visual centre with the number + the pill.
// Used by the bar entries (icon size is Globals.barIconSize; override font.pixelSize
// per instance when needed, e.g. the battery's discharging glyph).
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
