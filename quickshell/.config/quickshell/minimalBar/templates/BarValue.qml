import QtQuick
import QtQuick.Layouts
import qs.templates

// one bar reading: line icon + value. Untinted, the icon sits a tier below the value like the
// menu rows; a status tint (warning / critical / healthy) colours both so the alert reads at a glance
RowLayout {
    id: root

    property string icon: ""   // MenuIcon name
    property string text: ""
    property color tint: Globals.fgColor
    // drawn icons (battery, wifi, logo) go here instead of a MenuIcon name; colour them with iconColor.
    // A named icon wins: the slot then takes no space, even though its (hidden) children still exist
    default property alias glyph: glyphSlot.data

    readonly property color iconColor: Qt.colorEqual(tint, Globals.fgColor) ? Qt.alpha(Globals.fgColor, Globals.barIconAlpha) : tint

    spacing: Globals.barGlyphGap

    MenuIcon {
        visible: root.icon !== ""
        name: root.icon
        color: root.iconColor
        strokeWidth: Globals.barIconStroke
        Layout.preferredWidth: Globals.barIconSize
        Layout.preferredHeight: Globals.barIconSize
    }

    Item {
        id: glyphSlot
        visible: root.icon === "" && children.length > 0
        Layout.preferredWidth: Globals.barIconSize
        Layout.preferredHeight: Globals.barIconSize
    }

    Text {
        visible: root.text !== ""
        text: root.text
        font: Globals.barFont
        color: root.tint
    }
}
