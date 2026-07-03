pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import qs.defaults

import QtQuick

PanelWindow { // qmllint disable uncreatable-type
    id: root

    // bind this to the owning open-state; dismissed() fires on outside-click / Escape
    property bool open: false
    signal dismissed

    // every key press is forwarded here; accept the event to consume it, otherwise an unaccepted Escape dismisses the popup
    signal keyDown(var event)

    // card x-placement against the window: "left" | "center" | "right"
    property string hAlign: "left"
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

    // force Wayland to send keyboard events here so the popup can capture typing
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // forward every keypress to the owner; an unaccepted Escape closes the popup
    Item {
        focus: true
        Keys.onPressed: event => {
            root.keyDown(event);
            if (!event.accepted && event.key === Qt.Key_Escape)
                root.dismissed();
        }
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
        anchors.horizontalCenter: root.hAlign === "center" ? parent.horizontalCenter : undefined
        anchors.left: root.hAlign === "left" ? parent.left : undefined
        anchors.right: root.hAlign === "right" ? parent.right : undefined

        // size to what ever the nested content is plus padding on every side
        implicitWidth: contentHolder.childrenRect.width + root.padding * 2
        implicitHeight: contentHolder.childrenRect.height + root.padding * 2

        // smooth the size change when a menu swaps its body (e.g. audio <-> bluetooth); menus that keep a fixed size while open never trigger this
        Behavior on implicitWidth {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.OutCubic
            }
        }

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
