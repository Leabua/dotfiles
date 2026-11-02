import QtQuick
import QtQuick.Layouts
import qs.templates

// A quiet label with its reading aligned to the section's right edge.
RowLayout {
    id: root

    property string key: ""
    property string val: ""
    property color valColor: Globals.surfaceContent

    Layout.fillWidth: true
    spacing: Globals.spacing

    Text {
        text: root.key
        color: Globals.surfaceVariantContent
        font: Globals.bodySmall
    }
    Item {
        Layout.fillWidth: true
    }
    Text {
        text: root.val
        color: root.valColor
        font: Globals.labelMedium
    }
}
