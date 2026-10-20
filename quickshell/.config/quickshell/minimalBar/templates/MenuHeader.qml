import QtQuick
import QtQuick.Layouts
import qs.templates

RowLayout {
    id: header

    property string title: ""
    property string icon: ""
    property string actionText: ""
    property string actionIcon: ""
    property bool actionDestructive: false
    property bool actionEnabled: true
    property bool showToggle: false
    property bool toggleEnabled: true
    property bool checked: false
    signal actionClicked
    signal toggleRequested
    signal closeRequested

    Layout.fillWidth: true
    Layout.leftMargin: 10 // header glyph shares the rows' icon column
    spacing: 10

    MenuIcon {
        visible: Globals.headerIcons && header.icon !== ""
        name: header.icon
        color: Globals.fgColor
        Layout.preferredWidth: 22
        Layout.preferredHeight: 22
    }

    Text {
        Layout.fillWidth: true
        text: header.title
        color: Globals.fgColor
        font.family: Globals.textFont.family
        font.pixelSize: 20
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    MenuButton {
        visible: header.actionText !== ""
        text: header.actionText
        icon: header.actionIcon
        destructive: header.actionDestructive
        enabled: header.actionEnabled
        onClicked: header.actionClicked()
    }

    MenuToggle {
        visible: header.showToggle
        enabled: header.toggleEnabled
        checked: header.checked
        onToggled: header.toggleRequested()
    }

    MenuButton {
        icon: "close"
        onClicked: header.closeRequested()
    }
}
