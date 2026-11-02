import QtQuick
import QtQuick.Layouts
import qs.templates

// one rail reading: a line icon with an optional label under it (M3 rail item anatomy). Untinted it takes
// its host item's content colour, so it flips with the active indicator; a status tint overrides that
ColumnLayout {
    id: root

    property string icon: ""       // MenuIcon name
    property string text: ""
    property color tint: "transparent" // warning / critical / healthy; transparent -> follow the host
    // drawn icons (battery, wifi) go here instead of a MenuIcon name; colour them with iconColor
    default property alias glyph: glyphSlot.data

    // the nearest BarButton up the tree, for its content colour
    readonly property Item host: {
        let p = parent;
        while (p && p.contentColor === undefined)
            p = p.parent;
        return p;
    }
    readonly property color iconColor: tint.a > 0 ? tint : host ? host.contentColor : Globals.surfaceVariantContent

    spacing: 2
    Layout.alignment: Qt.AlignHCenter

    MenuIcon {
        visible: root.icon !== ""
        name: root.icon
        color: root.iconColor
        strokeWidth: Globals.barIconStroke
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Globals.barIconSize
        Layout.preferredHeight: Globals.barIconSize
    }

    Item {
        id: glyphSlot
        visible: root.icon === "" && children.length > 0
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: Globals.barIconSize
        Layout.preferredHeight: Globals.barIconSize
    }

    Text {
        visible: root.text !== ""
        text: root.text
        font: Globals.labelSmall
        color: root.iconColor
        Layout.alignment: Qt.AlignHCenter
    }
}
