import QtQuick
import qs.templates

// M3 switch: off is an outlined track with a small outline-coloured thumb; on fills the track with primary
// and the thumb grows to carry a check. The thumb travels with a light overshoot and swells while pressed
Rectangle {
    id: toggle
    property bool checked: false
    signal toggled

    implicitWidth: 52
    implicitHeight: 32
    radius: height / 2
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.38
    color: checked ? Globals.primary : Globals.surfaceContainerHighest
    border.width: checked ? 0 : 2
    border.color: Globals.outline
    Behavior on color {
        ColorAnimation {
            duration: Globals.animDuration
        }
    }
    Keys.onSpacePressed: toggled()
    Keys.onReturnPressed: toggled()

    Rectangle {
        id: thumb
        readonly property int target: mouse.pressed ? 28 : toggle.checked ? 24 : 16
        width: target
        height: target
        radius: width / 2
        anchors.verticalCenter: parent.verticalCenter
        x: toggle.checked ? toggle.width - width - 4 : (mouse.pressed ? 2 : 8)
        color: toggle.checked ? Globals.primaryContent : Globals.outline
        Behavior on x {
            NumberAnimation {
                duration: Globals.animEnter
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeSpatial
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeSpatial
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeSpatial
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: Globals.animDuration
            }
        }

        MenuIcon {
            anchors.centerIn: parent
            width: 16
            height: 16
            name: "check"
            color: Globals.primary
            strokeWidth: 2.2
            opacity: toggle.checked ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: Globals.animFast
                }
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: toggle.toggled()
    }
}
