pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import qs.templates

import QtQuick

PanelWindow { // qmllint disable uncreatable-type
    id: root

    // open on whichever monitor is focused so the menu lands where you're working
    screen: Globals.focusedScreen

    // bind this to the owning open-state; dismissed() fires on outside-click / Escape
    property bool open: false
    signal dismissed

    // every key press is forwarded here; accept the event to consume it, otherwise an unaccepted Escape dismisses the popup
    signal keyDown(var event)

    // card x-placement against the window: "left" | "center" | "right"
    property string hAlign: "left"
    // scene-x of the bar button that opened this; -1 = not button-anchored (use hAlign)
    property real anchorCenterX: -1
    // button-anchored menus snap to the nearest screen edge so they never clip
    readonly property string _align: {
        if (anchorCenterX < 0)
            return hAlign;
        const w = screen ? screen.width : width;
        if (anchorCenterX > w * 0.55)
            return "right";
        if (anchorCenterX < w * 0.45)
            return "left";
        return "center";
    }
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

    // ~~~ leave the bar strip out of the input region so bar icons stay clickable while a menu is open ~~~
    mask: Region {
        x: 0
        y: root.margins.top
        width: root.width
        height: root.height - root.margins.top
    }

    // force Wayland to send keyboard events here so the popup can capture typing
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // ~~~ publish the card's screen rect while open -> the toasts read it and drop below a menu that lands on top of them ~~~
    Binding {
        target: Globals
        property: "menuCardRect"
        value: Qt.rect(root.margins.left + card.x, root.margins.top + card.y, card.width, card.height)
        when: root.open
    }

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

        // stay on a single left anchor and shift the card with the margin instead of
        // swapping left / right anchors -> having both set at once (even for one frame
        // while _align changes) hands width over to the anchor system and permanently
        // kills the implicitWidth sizing below, leaving the card stretched full-width
        anchors.left: parent.left
        anchors.leftMargin: {
            const slack = Math.max(0, root.width - card.width);
            if (root._align === "right")
                return slack;
            if (root._align === "center")
                return slack / 2;
            return 0;
        }

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
