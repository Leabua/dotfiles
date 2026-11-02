import QtQuick
import qs.templates

// battery drawn in the MenuIcon line style; the cell fills to the real charge instead of
// stepping through ten glyphs, and a bolt cut across the whole battery marks charging
Item {
    id: root

    property real level: 0 // 0..1
    property bool charging: false
    property color color: Globals.fgColor
    property real strokeWidth: 1.7

    readonly property color hue: Qt.rgba(color.r, color.g, color.b, 1)
    readonly property real cellWidth: level > 0 ? Math.max(1.5, 13 * Math.min(1, level)) : 0
    readonly property string bolt: "M13.5 2.5 7 13h4.5L10 21.5l6.5-10.5H12z"

    implicitWidth: 18
    implicitHeight: 18

    Image {
        anchors.fill: parent
        sourceSize.width: Math.ceil(width)
        sourceSize.height: Math.ceil(height)
        opacity: root.color.a
        source: "data:image/svg+xml," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="' + root.hue + '" stroke-width="' + root.strokeWidth + '" stroke-linecap="round" stroke-linejoin="round">'
            + '<rect x="2" y="7" width="18" height="10" rx="2.5"/><path d="M22.5 10.5v3"/>'
            + '<rect x="4.5" y="9.5" width="' + root.cellWidth + '" height="5" rx="1" fill="' + root.hue + '" stroke="none"/>'
            // a bolt inside a 3px cell is a smudge at bar size, so it crosses the whole battery instead:
            // drawn once fat in the background colour to cut it out of the outline, then filled on top
            + (root.charging ? '<path d="' + root.bolt + '" stroke="' + Globals.bgColor + '" stroke-width="3" fill="' + Globals.bgColor + '"/><path d="' + root.bolt + '" fill="' + root.hue + '" stroke="none"/>' : '')
            + '</svg>')
    }
}
