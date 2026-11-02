import QtQuick
import QtQuick.Controls
import qs.templates

// M3 Expressive slider: a thick 16px track split by a tall 4px handle with a gap either side. The active
// side is primary, the inactive side a quiet container tone with a stop dot at its end. The handle thins
// while dragged so the value under it stays visible. `dimmed` (muted) greys the active side out
Slider {
    id: control

    property bool dimmed: false
    readonly property int trackHeight: 16
    readonly property int handleWidth: pressed ? 2 : 4
    readonly property int gap: 6
    readonly property color activeColor: dimmed ? Qt.alpha(Globals.surfaceContent, 0.38) : Globals.primary

    implicitHeight: 40
    padding: 0

    background: Item {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: control.trackHeight

        readonly property real handleX: control.visualPosition * (width - control.handleWidth)

        // active side -> fully round at the start, tight corners where it meets the handle
        Rectangle {
            width: Math.max(0, parent.handleX - control.gap)
            height: parent.height
            topLeftRadius: height / 2
            bottomLeftRadius: height / 2
            topRightRadius: 2
            bottomRightRadius: 2
            color: control.activeColor
            visible: width > 0
        }

        // inactive side
        Rectangle {
            x: parent.handleX + control.handleWidth + control.gap
            width: Math.max(0, parent.width - x)
            height: parent.height
            topLeftRadius: 2
            bottomLeftRadius: 2
            topRightRadius: height / 2
            bottomRightRadius: height / 2
            color: Globals.surfaceContainerHighest
            visible: width > 0

            // stop indicator
            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 6
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 4
                radius: 2
                color: control.activeColor
                visible: parent.width > 16
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + (control.availableHeight - height) / 2
        implicitWidth: control.handleWidth
        implicitHeight: 36
        radius: width / 2
        color: control.activeColor
        Behavior on implicitWidth {
            NumberAnimation {
                duration: Globals.animFast
            }
        }
    }
}
