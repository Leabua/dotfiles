import QtQuick
import QtQuick.Window
import QtQuick.Shapes
import qs.templates

// M3 Expressive wavy linear progress: the filled part is a sine wave, then a gap, then a flat track with a
// stop dot. The wave flattens out near 0 and 100 so the ends never look like a glitch. New readings ease in,
// and while its window is on screen the wave keeps travelling forward -> a live reading that looks alive
Item {
    id: root

    property real value: 0 // 0..1
    property color color: Globals.primary
    property color trackColor: Globals.surfaceContainerHighest
    property real thickness: 4
    property real amplitude: 3
    property real wavelength: 22
    property int period: 1400 // ms for the wave to travel one wavelength

    // only animate while the window holding it is mapped (a closed menu costs nothing)
    readonly property bool onScreen: Window.window !== null && Window.window.visible
    // how far the wave has travelled within one wavelength. Only this moves per frame: the wave is drawn once
    // and slid sideways inside a clipped strip (a transform), never re-tessellated while it travels
    property real offset: 0
    NumberAnimation on offset {
        from: 0
        to: root.wavelength
        duration: root.period
        loops: Animation.Infinite
        running: root.onScreen && root.activeWidth > root.thickness
    }

    function waveY(x: real): real {
        return root.height / 2 + root.amp * Math.sin((x - root.offset) / root.wavelength * Math.PI * 2);
    }

    // eased copy of value -> readings glide rather than jump
    property real shown: value
    Behavior on shown {
        NumberAnimation {
            duration: 360
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }

    readonly property real clamped: Math.max(0, Math.min(1, shown))
    readonly property real gap: 6
    readonly property real activeWidth: clamped * width
    // calm the wave at the extremes
    readonly property real amp: amplitude * Math.min(1, clamped * 8, (1 - clamped) * 8 + 0.35)

    implicitHeight: amplitude * 2 + thickness + 2

    readonly property real waveStart: thickness / 2
    readonly property real waveEnd: Math.max(waveStart, activeWidth - thickness / 2)

    // the filled part: a clipped window onto a wave one wavelength longer than the bar
    Item {
        x: root.waveStart
        width: root.waveEnd - root.waveStart
        height: root.height
        clip: true
        visible: root.activeWidth > root.thickness

        Shape {
            // slid so the strip shows the wave at phase `offset`; the path itself only changes with size / amplitude
            x: root.offset - root.wavelength - root.waveStart
            width: root.width + root.wavelength
            height: root.height
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: root.color
                strokeWidth: root.thickness
                fillColor: "transparent"
                joinStyle: ShapePath.RoundJoin

                PathPolyline {
                    path: {
                        const pts = [];
                        const mid = root.height / 2;
                        const len = root.width + root.wavelength;
                        const steps = Math.max(2, Math.ceil(len / 2));
                        for (let i = 0; i <= steps; i++) {
                            const x = len * i / steps;
                            pts.push(Qt.point(x, mid + root.amp * Math.sin(x / root.wavelength * Math.PI * 2)));
                        }
                        return pts;
                    }
                }
            }
        }
    }

    // round caps for the clipped ends, riding the wave as it travels
    Repeater {
        model: root.activeWidth > root.thickness ? [root.waveStart, root.waveEnd] : []
        delegate: Rectangle {
            required property real modelData
            x: modelData - width / 2
            y: root.waveY(modelData) - height / 2
            width: root.thickness
            height: root.thickness
            radius: width / 2
            color: root.color
        }
    }

    // flat remainder of the track
    Rectangle {
        x: Math.min(root.width, root.activeWidth + root.gap)
        width: Math.max(0, root.width - x)
        height: root.thickness
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: root.trackColor
        visible: width > root.thickness

        // stop indicator
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: root.thickness
            height: root.thickness
            radius: width / 2
            color: root.color
        }
    }
}
