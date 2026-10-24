import QtQuick
import QtQuick.Controls
import qs.templates

// the audio menu's track: 4px rail, inked fill, handle only while touched
Slider {
    id: control

    property bool dimmed: false

    implicitHeight: 28
    padding: 0
    focusPolicy: Qt.NoFocus // arrow keys belong to the preview, not the slider

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 4
        radius: 2
        color: Qt.alpha(Globals.fgColor, 0.12)

        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Qt.alpha(Globals.fgColor, control.dimmed ? 0.35 : 0.9)
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: 12
        implicitHeight: 12
        radius: 6
        color: Globals.fgColor
        visible: control.hovered || control.pressed
    }
}
