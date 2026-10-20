import QtQuick
import qs.templates

Rectangle {
    id: toggle
    property bool checked: false
    signal toggled

    implicitWidth: 34
    implicitHeight: 20
    radius: height / 2
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.35
    color: checked ? Globals.fgColor : Qt.alpha(Globals.fgColor, 0.2)
    Behavior on color {
        ColorAnimation {
            duration: Globals.animDuration
        }
    }
    border.width: activeFocus ? 1 : 0
    border.color: Qt.alpha(Globals.fgColor, 0.6)
    Keys.onSpacePressed: toggled()
    Keys.onReturnPressed: toggled()

    Rectangle {
        width: 14
        height: 14
        radius: 7
        y: 3
        x: toggle.checked ? toggle.width - width - 3 : 3
        color: toggle.checked ? Globals.bgColor : Globals.fgColor
        // the knob travels rather than teleports -> the switch reads as a physical thing
        Behavior on x {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.toggled()
    }
}
