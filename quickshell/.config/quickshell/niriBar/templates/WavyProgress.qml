import QtQuick
import QtQuick.Shapes
import qs.templates

// M3 Expressive wavy linear progress: the filled part is a sine wave, then a gap, then a flat track with a
// stop dot. The wave flattens out near 0 and 100 so the ends never look like a glitch. New readings ease in
Item {
    id: root

    property real value: 0 // 0..1
    property color color: Globals.primary
    property color trackColor: Globals.surfaceContainerHighest
    property real thickness: 4
    property real amplitude: 3
    property real wavelength: 22

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

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        visible: root.activeWidth > root.thickness

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.thickness
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            fillColor: "transparent"

            PathPolyline {
                path: {
                    const pts = [];
                    const mid = root.height / 2;
                    const start = root.thickness / 2;
                    const end = Math.max(start, root.activeWidth - root.thickness / 2);
                    const steps = Math.max(2, Math.ceil((end - start) / 2));
                    for (let i = 0; i <= steps; i++) {
                        const x = start + (end - start) * i / steps;
                        pts.push(Qt.point(x, mid + root.amp * Math.sin(x / root.wavelength * Math.PI * 2)));
                    }
                    return pts;
                }
            }
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
