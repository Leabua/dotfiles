import QtQuick
import QtQuick.Layouts
import qs.templates

// one large power action. Hover / keyboard selection morph the corners rounder (M3 Expressive shape change).
// `hold` actions only fire after a press is held for holdMs: a fill sweeps across slowly and linearly while
// you decide, and snaps back fast if you let go early. A plain click works for the rest
Rectangle {
    id: tile

    property string label: ""
    property string icon: ""
    property bool hold: false
    property bool danger: false
    property bool selected: false
    property int holdMs: 800
    property real progress: 0
    signal activated
    signal hovered

    readonly property bool lit: selected || mouse.containsMouse
    readonly property color content: danger ? Globals.errorContainerContent : Globals.surfaceContent

    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 100
    radius: lit ? 36 : Globals.shapeLargeIncreased
    color: danger ? Globals.errorContainer : Globals.surfaceContainerHigh

    Behavior on radius {
        NumberAnimation {
            duration: Globals.animEnter
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeSpatial
        }
    }
    scale: mouse.pressed && !tile.hold ? 0.97 : 1
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
        color: tile.content
        opacity: tile.lit ? Globals.stateHover : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animFast
            }
        }
    }

    // hold-to-confirm fill
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: tile.progress * tile.width
        radius: Math.min(tile.radius, width / 2)
        color: tile.content
        opacity: 0.2
        visible: tile.progress > 0
    }

    // press: slow and linear while deciding. release: fast and eased, the system answering
    NumberAnimation {
        id: fill
        target: tile
        property: "progress"
        to: 1
        duration: tile.holdMs * (1 - tile.progress)
        onFinished: if (tile.progress >= 1)
            tile.activated()
    }
    NumberAnimation {
        id: release
        target: tile
        property: "progress"
        to: 0
        duration: 200
        easing.type: Easing.BezierSpline
        easing.bezierCurve: Globals.easeOut
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 8

        MenuIcon {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 28
            Layout.preferredHeight: 28
            name: tile.icon
            color: tile.content
            strokeWidth: 1.8
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: tile.label
            color: tile.content
            font: Globals.titleSmall
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: tile.hovered()
        onPressed: {
            if (!tile.hold)
                return;
            release.stop();
            fill.start();
        }
        onReleased: {
            if (!tile.hold || tile.progress >= 1)
                return;
            fill.stop();
            release.start();
        }
        onCanceled: {
            fill.stop();
            release.start();
        }
        onClicked: if (!tile.hold)
            tile.activated()
    }

    // a fresh menu never opens mid-sweep
    function reset(): void {
        fill.stop();
        release.stop();
        progress = 0;
    }
}
