import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.templates

// the rail's one loud element: hours over minutes in Roboto Flex squeezed to its narrowest width, set on a
// primary-container block like an M3 Expressive alarm card. Click for the date (day over month), click back
Rectangle {
    id: root

    property bool showDate: false

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    implicitWidth: Globals.railItemWidth
    implicitHeight: digits.implicitHeight + 14
    Layout.alignment: Qt.AlignHCenter
    radius: Globals.shapeLarge
    color: Globals.primaryContainer

    scale: mouse.pressed ? 0.94 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }

    // state layer
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Globals.primaryContainerContent
        opacity: mouse.pressed ? Globals.statePressed : mouse.containsMouse ? Globals.stateHover : 0
    }

    Text {
        id: digits
        anchors.centerIn: parent
        text: Qt.formatDateTime(clock.date, root.showDate ? "dd\nMM" : "hh\nmm")
        font: Globals.clockFont
        color: Globals.primaryContainerContent
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 0.86 // the two rows read as one block
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Globals.dismissPopup();
            root.showDate = !root.showDate;
        }
    }
}
