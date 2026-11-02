import QtQuick
import QtQuick.Layouts
import qs.templates

// the overlay's reading: the icon in a tonal circle, a thick M3 Expressive track (primary up to the level,
// a gap, then the quiet remainder with its stop dot), and the number. Muted greys the level out
RowLayout {
    id: root

    property string icon: ""
    property int percent: 0
    property bool dimmed: false

    readonly property real level: Math.max(0, Math.min(1, percent / 100))
    readonly property color activeColor: dimmed ? Qt.alpha(Globals.surfaceContent, 0.38) : Globals.primary

    spacing: 14

    Rectangle {
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: 20
        color: root.dimmed ? Globals.surfaceContainerHighest : Globals.secondaryContainer

        MenuIcon {
            anchors.centerIn: parent
            width: 22
            height: 22
            name: root.icon
            color: root.dimmed ? Globals.surfaceVariantContent : Globals.secondaryContainerContent
        }
    }

    Item {
        id: track
        Layout.fillWidth: true
        implicitHeight: 14

        // eased fill -> key repeats retarget mid-flight instead of stepping
        property real shown: root.level
        Behavior on shown {
            NumberAnimation {
                duration: Globals.animDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }
        readonly property real split: shown * width

        Rectangle {
            width: Math.max(height, track.split - 3)
            height: parent.height
            topLeftRadius: height / 2
            bottomLeftRadius: height / 2
            topRightRadius: track.shown >= 0.99 ? height / 2 : 3
            bottomRightRadius: track.shown >= 0.99 ? height / 2 : 3
            color: root.activeColor
            visible: track.shown > 0.005
        }

        Rectangle {
            x: track.split + 3
            width: Math.max(0, parent.width - x)
            height: parent.height
            topLeftRadius: 3
            bottomLeftRadius: 3
            topRightRadius: height / 2
            bottomRightRadius: height / 2
            color: Globals.surfaceContainerHighest
            visible: width > height

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                width: 4
                height: 4
                radius: 2
                color: root.activeColor
            }
        }
    }

    Text {
        Layout.preferredWidth: 36
        text: root.dimmed ? "Off" : root.percent
        color: Globals.surfaceContent
        horizontalAlignment: Text.AlignRight
        font: Globals.titleMedium
    }
}
