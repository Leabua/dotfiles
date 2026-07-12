import QtQuick
import QtQuick.Shapes
import qs.templates

// Speedtest-style radial gauge: a faint 270deg track with a heat-coloured
// progress arc riding over it, and a big glyph (+ optional % caption) sitting in
// the open centre. `value` is 0..1; the arc animates as it changes.
Item {
    id: root

    property real value: 0        // 0..1, drives the arc sweep
    property string glyph: ""     // centre icon (nerd-font glyph)
    property string caption: ""   // small line under the glyph (e.g. "62%")
    property color arcColor: Globals.fgColor
    property real diameter: 104
    property real thickness: 8

    // arc opens at the bottom: start bottom-left (135deg), sweep 270deg CW over
    // the top to bottom-right, leaving a 90deg gap centred on 6 o'clock
    readonly property real _span: 270
    readonly property real _start: 135
    readonly property real _clamped: Math.max(0, Math.min(1, value))
    // keep the round caps inside the item bounds
    readonly property real _radius: (diameter - thickness) / 2

    implicitWidth: diameter
    implicitHeight: diameter

    Shape {
        anchors.fill: parent
        antialiasing: true
        layer.enabled: true
        layer.samples: 4 // multisample the arc so the caps stay smooth

        // background track
        ShapePath {
            strokeColor: Qt.alpha(Globals.fgColor, 0.15)
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root._start
                sweepAngle: root._span
            }
        }

        // progress arc
        ShapePath {
            strokeColor: root.arcColor
            strokeWidth: root.thickness
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root._radius
                radiusY: root._radius
                startAngle: root._start
                sweepAngle: root._span * root._clamped
                Behavior on sweepAngle {
                    NumberAnimation {
                        duration: Globals.animDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }

            Behavior on strokeColor {
                ColorAnimation {
                    duration: Globals.animDuration
                }
            }
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: 1

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.glyph
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: root.diameter * 0.32
            font.weight: Globals.textFont.weight
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.caption !== ""
            text: root.caption
            color: Qt.alpha(Globals.fgColor, 0.75)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 2
            font.weight: Globals.textFont.weight
        }
    }
}
