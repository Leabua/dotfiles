pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import qs.defaults

import QtQuick

// Friendly reminder to future me when I get to kanban and calendar integration -> basically jsut a wrapper util

// Reusable popup chrome for the second-order menus (PowerMenu, PowerProfiles,
// Clipboard, and the upcoming audio/bluetooth/wifi cards).
//
// Provides: a full-screen transparent layer-shell window that grabs keyboard
// focus, closes on any keypress or on a click outside the card, and a styled
// card (menuBg + radius + border) that swallows its own clicks and sizes itself
// to whatever content you nest inside it.
//
// Usage:
//   PopupWindow {
//       open: Globals.somethingOpen          // bind to your open-state
//       onDismissed: Globals.somethingOpen = false
//       centered: true                       // top-centre (power menus) vs top-left
//       cardTopMargin: ...                   // extra offset below the window top margin
//       margins { top: ...; left: ...; right: ... }   // PanelWindow margins as usual
//
//       ColumnLayout { ...your content... }  // self-sizing, no anchors needed
//   }

PanelWindow { // qmllint disable uncreatable-type
    id: root

    // bind this to the owning open-state; dismissed() fires on outside-click / keypress
    property bool open: false
    signal dismissed

    // card placement: top-centre when true, otherwise top-left
    property bool centered: false
    // extra top offset added on top of the window's top margin
    property real cardTopMargin: 0
    // inner padding between the card edge and the content
    property real padding: Globals.margins

    // nested content lands in the card body and drives the card size
    default property alias content: contentHolder.data

    visible: open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore // Wayland: don't reserve screen space

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // force Wayland to send keyboard events here so typing closes the popup
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // close on any keypress
    Item {
        focus: true
        Keys.onPressed: event => root.dismissed()
    }

    // close on click outside the card
    MouseArea {
        anchors.fill: parent
        onClicked: root.dismissed()
    }

    Rectangle {
        id: card
        anchors.top: parent.top
        anchors.topMargin: root.cardTopMargin
        anchors.horizontalCenter: root.centered ? parent.horizontalCenter : undefined
        anchors.left: root.centered ? undefined : parent.left

        // size to what ever the nested content is plus padding on every side
        implicitWidth: contentHolder.childrenRect.width + root.padding * 2
        implicitHeight: contentHolder.childrenRect.height + root.padding * 2

        color: Globals.menuBg
        radius: Globals.radius
        border.width: Globals.borderWidth
        border.color: Globals.borderColor

        // swallow clicks on the card so they don't fall through to the close handler
        MouseArea {
            anchors.fill: parent
        }

        // content sits at the padding offset; childrenRect (above) measures it
        Item {
            id: contentHolder
            x: root.padding
            y: root.padding
        }
    }
}
