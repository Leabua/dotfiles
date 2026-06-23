import Quickshell
import QtQuick
import qs.defaults

Item {
    id: root
    property bool showDate: false

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: textID
        text: root.showDate ? Qt.formatDateTime(clock.date, "hh:mm - dd MMM") : Qt.formatDateTime(clock.date, "hh:mm")
        color: Globals.fgColor
        font: Globals.textFont
        opacity: 1.0 // Explicitly define opacity so we can animate it
    }

    // The custom timeline that handles the fade and delay
    SequentialAnimation {
        id: toggleAnimation

        // 1. Fade out the text quickly
        NumberAnimation {
            target: textID
            property: "opacity"
            to: 0
            duration: 150
            easing.type: Easing.OutQuad
        }

        // 2. Flip the boolean while the text is invisible.
        // This instantly updates the text string and implicitWidth,
        // which tells the parent bar to start its 250ms size animation.
        PropertyAction {
            target: root
            property: "showDate"
            value: !root.showDate
        }

        // 3. Pause to let the parent bar finish resizing (matching your 250ms bar duration)
        PauseAnimation {
            duration: 250
        }

        // 4. Fade the new text back in
        NumberAnimation {
            target: textID
            property: "opacity"
            to: 1.0
            duration: 150
            easing.type: Easing.InQuad
        }
    }

    // MouseArea {  // old onClick event
    //     id: mouse
    //     anchors.fill: parent
    //     anchors.margins: -1
    //     cursorShape: Qt.PointingHandCursor
    //
    //     onClicked: {
    //         // Only trigger if it isn't already animating to prevent spam-clicking glitches
    //         if (!toggleAnimation.running) {
    //             toggleAnimation.restart();
    //         }
    //     }
    // }

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor

        // 1. You MUST set this to true for QML to track the mouse without clicking
        hoverEnabled: true

        // 2. Trigger when the mouse enters the bounding box
        onEntered: {
            // Check state to prevent glitches if you scrub the mouse back and forth
            if (!root.showDate && !toggleAnimation.running) {
                toggleAnimation.restart();
            }
        }

        // 3. Revert back to the clock when the mouse leaves
        onExited: {
            if (root.showDate && !toggleAnimation.running) {
                toggleAnimation.restart();
            }
        }
    }
}
