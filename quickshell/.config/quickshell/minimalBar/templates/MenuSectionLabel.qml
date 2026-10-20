import QtQuick
import QtQuick.Layouts
import qs.templates

// quiet heading above a group of rows; the inset lines it up with the rows' icons
Text {
    property int inset: 10

    Layout.leftMargin: inset
    color: Qt.alpha(Globals.fgColor, 0.45)
    font.family: Globals.textFont.family
    font.pixelSize: 12
}
