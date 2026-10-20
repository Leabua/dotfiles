import QtQuick
import QtQuick.Layouts
import qs.templates

// icon + level track shown in the left island; the track matches the audio menu's volume slider
RowLayout {
    id: root

    property string icon: ""
    property int percent: 0
    property bool dimmed: false // muted -> the level is still shown, just quieter

    spacing: Globals.spacing + 2
    Layout.preferredWidth: OsdState.fixedWidth

    MenuIcon {
        name: root.icon
        color: Qt.alpha(Globals.fgColor, Globals.barIconAlpha)
        strokeWidth: Globals.barIconStroke
        Layout.preferredWidth: Globals.barIconSize
        Layout.preferredHeight: Globals.barIconSize
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 4
        radius: 2
        color: Qt.alpha(Globals.fgColor, 0.12)

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * Math.min(1, root.percent / 100)
            radius: parent.radius
            color: Qt.alpha(Globals.fgColor, root.dimmed ? 0.35 : 0.9)
            // key repeats retarget mid-flight -> a short ease-out keeps up without lagging the key
            Behavior on width {
                NumberAnimation {
                    duration: Globals.animDuration
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
