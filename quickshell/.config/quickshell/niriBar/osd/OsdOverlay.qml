import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.templates
import qs.osd

// volume / brightness, floating over the top-right corner of the focused output for a second after a change.
// Reads OsdState (pipewire + the backlight); overlays windows rather than pushing them, and takes no clicks
PanelWindow { // qmllint disable uncreatable-type
    id: root

    readonly property bool showing: OsdState.active !== ""

    // hold the last reading while fading out so the island doesn't flip to empty mid-fade
    property string kind: "volume"
    Connections {
        target: OsdState
        function onActiveChanged() {
            if (OsdState.active !== "")
                root.kind = OsdState.active;
        }
    }

    screen: Globals.focusedScreen ?? Quickshell.screens[0]
    color: "transparent"
    WlrLayershell.namespace: "niribar-osd"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Ignore // overlays windows rather than pushing them
    mask: Region {} // purely visual -> clicks fall through to whatever is underneath

    anchors {
        top: true
        right: true
    }
    margins {
        top: Globals.marginsTop
        right: Globals.marginsRight
    }

    // room left of and under the island for its shadow (top / right sit against the screen edge anyway)
    readonly property int shadowRoom: 24
    implicitWidth: island.width + shadowRoom
    implicitHeight: island.height + shadowRoom
    visible: island.opacity > 0.01

    // M3 elevation for something floating over arbitrary windows
    RectangularShadow {
        anchors.fill: island
        radius: island.radius
        offset.y: 4
        blur: 18
        spread: -2
        color: Qt.alpha("#000000", 0.5)
        opacity: island.opacity
        transform: Translate {
            y: island.dropY
        }
    }

    // a full-pill floating surface; drops in from just above and fades, leaves with a plain fade.
    // Volume keys repeat -> while it's showing, new readings only move the track, nothing re-enters
    Rectangle {
        id: island
        anchors.right: parent.right
        anchors.top: parent.top
        width: 340
        height: 60
        radius: height / 2
        color: Globals.surfaceContainerHigh

        opacity: root.showing ? 1 : 0
        property real dropY: root.showing ? 0 : -8
        Behavior on dropY {
            NumberAnimation {
                duration: Globals.animEnter
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }
        transform: Translate {
            y: island.dropY
        }
        Behavior on opacity {
            NumberAnimation {
                duration: root.showing ? Globals.animDuration : 220
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }

        OsdMeter {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 22
            percent: root.kind === "volume" ? OsdState.volPercent : OsdState.brightPercent
            dimmed: root.kind === "volume" && OsdState.volMuted
            icon: {
                if (root.kind === "brightness")
                    return OsdState.brightPercent < 50 ? "sunDim" : "sun";
                if (OsdState.volMuted || OsdState.volPercent === 0)
                    return "speakerMuted";
                if (OsdState.volPercent < 34)
                    return "speakerLow";
                if (OsdState.volPercent < 67)
                    return "speakerMedium";
                return "speaker";
            }
        }
    }
}
