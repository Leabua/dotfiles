import QtQuick
import QtQuick.Layouts
import qs.templates

// M3 card header: the menu's glyph in a tonal circle, a title-large name, then optional action button and
// switch. No close button: Escape, a click outside or the trigger again all dismiss a menu
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
    signal closeRequested // kept so menus' handlers still bind; nothing in the header emits it now

    Layout.fillWidth: true
    Layout.bottomMargin: 4
    spacing: 12

    Rectangle {
        visible: Globals.headerIcons && header.icon !== ""
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        color: Globals.secondaryContainer

        MenuIcon {
            anchors.centerIn: parent
            width: 22
            height: 22
            name: header.icon
            color: Globals.secondaryContainerContent
        }
    }

    Text {
        Layout.fillWidth: true
        text: header.title
        color: Globals.surfaceContent
        font: Globals.titleLarge
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
}
