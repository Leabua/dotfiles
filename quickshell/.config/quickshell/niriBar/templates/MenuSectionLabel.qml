import QtQuick
import QtQuick.Layouts
import qs.templates

// M3 list subheader: label-large in primary, lined up with the rows' leading icons
Text {
    property int inset: 16

    Layout.leftMargin: inset
    Layout.topMargin: 4
    color: Globals.primary
    font: Globals.labelLarge
}
