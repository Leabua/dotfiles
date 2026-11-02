pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Wayland
import qs.templates

import QtQuick
import QtQuick.Controls
import QtQuick.Effects

// every menu's frame: a full-screen overlay layer holding one M3 card (surface container, extra-large corners,
// a soft elevation shadow). Rail-opened menus open beside their trigger and grow out of it; keyboard-opened
// ones (launcher, clipboard, notifications) appear instantly because they're summoned many times a day
PanelWindow { // qmllint disable uncreatable-type
    id: root

    // open on whichever output is focused so the menu lands where you're working
    screen: Globals.focusedScreen

    // bind this to the owning open-state; dismissed() fires on outside-click / Escape
    property bool open: false
    signal dismissed

    // every key press is forwarded here; accept the event to consume it, otherwise an unaccepted Escape dismisses
    signal keyDown(var event)

    function focusMenu(): void {
        keyboardRoot.forceActiveFocus();
    }

    // card x-placement against the window when not opened from the rail: "left" | "center" | "right"
    property string hAlign: "left"
    property bool verticallyCentered: false
    // scene-x of the rail item that opened this; -1 = not rail-anchored (use hAlign)
    property real anchorCenterX: -1
    // rail-anchored -> the card opens beside the rail, centred on the trigger, and animates in from it
    readonly property bool _beside: anchorCenterX >= 0
    // extra top offset added on top of the window's top margin
    property real cardTopMargin: 0
    // inner padding between the card edge and the content
    property real padding: Globals.margins
    property color backgroundColor: Globals.menuBg
    readonly property real availableWidth: Math.max(1, width - padding * 2)
    readonly property real availableHeight: Math.max(1, height - Math.max(0, cardTopMargin) - padding * 2 - Globals.margins)

    // nested content lands in the card body and drives the card size
    default property alias content: contentHolder.data

    // stay mapped through the exit animation, then unmap
    visible: open || card.opacity > 0.01
    onOpenChanged: {
        if (open) {
            if (Globals.activePopup && Globals.activePopup !== root)
                Globals.activePopup.dismissed();
            Globals.activePopup = root;
            bodyScroll.contentY = 0;
            Qt.callLater(keyboardRoot.forceActiveFocus);
        } else if (Globals.activePopup === root) {
            Globals.activePopup = null;
            Globals.menuCardRect = Qt.rect(0, 0, 0, 0);
        }
    }
    Component.onDestruction: {
        if (Globals.activePopup === root)
            Globals.activePopup = null;
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // while closing, the layer is still mapped for the exit animation -> let clicks fall straight through it
    Region {
        id: noInput
    }
    mask: root.open ? null : noInput

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "niribar-popup"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // ~~~ publish the card's screen rect while open -> toasts drop below a menu that lands on top of them ~~~
    Binding {
        target: Globals
        property: "menuCardRect"
        value: Qt.rect(root.margins.left + card.x, root.margins.top + card.y, card.width, card.height)
        when: root.open
    }

    // forward every keypress to the owner; an unaccepted Escape closes the popup
    Item {
        id: keyboardRoot
        focus: true
        Keys.onPressed: event => {
            event.accepted = false;
            root.keyDown(event);
            if (!event.accepted && event.key === Qt.Key_Escape)
                root.dismissed();
        }
    }

    // close on a click outside the card
    MouseArea {
        anchors.fill: parent
        enabled: root.open
        acceptedButtons: Qt.AllButtons
        onClicked: root.dismissed()
    }

    // M3 elevation level 3 -> a soft, low shadow under the card; follows its scale and fade
    RectangularShadow {
        anchors.fill: card
        radius: card.radius
        offset.y: 6
        blur: 28
        spread: -4
        color: Qt.alpha("#000000", 0.45)
        opacity: card.opacity
        scale: card.scale
        transformOrigin: card.transformOrigin
    }

    Rectangle {
        id: card

        anchors.top: parent.top
        anchors.topMargin: {
            if (root._beside) // rail scene y is screen y -> shift into this window, then keep the card on screen
                return Math.max(0, Math.min(root.height - height - Globals.margins, Globals.menuAnchorY - root.margins.top - height / 2));
            if (root.verticallyCentered)
                return Math.max(0, (root.height - height) / 2);
            return Math.max(0, root.cardTopMargin);
        }

        // one left anchor, shifted by the margin -> never set left and right together (that hands width to the
        // anchors and breaks the implicitWidth sizing below)
        anchors.left: parent.left
        anchors.leftMargin: {
            if (root._beside) // clear the rail by the menu gap; flush to the edge while the rail is hidden
                return Math.max(0, (Globals.barShown ? Globals.railEdgeMargin + Globals.railWidth + Globals.hyprGaps : 0) - root.margins.left);
            const slack = Math.max(0, root.width - card.width);
            if (root.hAlign === "right")
                return slack;
            if (root.hAlign === "center")
                return slack / 2;
            return 0;
        }

        // size to the nested content plus padding on every side
        implicitWidth: Math.min(root.width, contentHolder.childrenRect.width + root.padding * 2)
        implicitHeight: Math.min(root.availableHeight + root.padding * 2, contentHolder.childrenRect.height + root.padding * 2)

        // a menu swapping its body (audio <-> bluetooth) eases to the new size
        Behavior on implicitWidth {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }

        // ~~~ enter / exit ~~~
        // rail-opened: grows out of the rail edge (0.94 -> 1, never from nothing) with a strong ease-out, and
        // leaves faster than it came. keyboard-opened: the Behaviors are off, so it's simply there
        transformOrigin: root._beside ? Item.Left : Item.Top
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.94
        Behavior on opacity {
            enabled: root._beside
            NumberAnimation {
                duration: root.open ? Globals.animEnter : Globals.animExit
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }
        Behavior on scale {
            enabled: root._beside
            NumberAnimation {
                duration: root.open ? Globals.animEnter : Globals.animExit
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }

        color: root.backgroundColor
        radius: Globals.radius
        border.width: Globals.borderWidth
        border.color: Globals.borderColor

        // swallow clicks on the card so they don't reach the close handler
        MouseArea {
            anchors.fill: parent
        }

        // content sits at the padding offset; childrenRect (above) measures it
        Flickable {
            id: bodyScroll
            x: root.padding
            y: root.padding
            width: card.width - root.padding * 2
            height: card.height - root.padding * 2
            contentWidth: contentHolder.childrenRect.width
            contentHeight: contentHolder.childrenRect.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            Item {
                id: contentHolder
                width: bodyScroll.width
                height: childrenRect.height
                Keys.onPressed: event => {
                    event.accepted = false;
                    root.keyDown(event);
                    if (!event.accepted && event.key === Qt.Key_Escape) {
                        root.dismissed();
                        event.accepted = true;
                    }
                }
            }
        }
    }
}
