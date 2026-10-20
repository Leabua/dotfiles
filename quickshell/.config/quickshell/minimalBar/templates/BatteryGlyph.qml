import QtQuick
import qs.templates

// battery drawn in the MenuIcon line style; the cell fills to the real charge instead of
// stepping through ten glyphs, and a knocked-out bolt marks charging
Item {
    id: root

    property real level: 0 // 0..1
    property bool charging: false
    property color color: Globals.fgColor
    property real strokeWidth: 1.7

    readonly property color hue: Qt.rgba(color.r, color.g, color.b, 1)
    readonly property real cellWidth: level > 0 ? Math.max(1.5, 13 * Math.min(1, level)) : 0

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
            + (root.charging ? '<path d="M12.2 7.6 9 12.4h3l-1.2 4 3.4-5h-3z" fill="' + Globals.bgColor + '" stroke-width="1.1"/>' : '')
            + '</svg>')
    }
}
