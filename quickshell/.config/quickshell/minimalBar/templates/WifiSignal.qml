import QtQuick
import qs.templates

// wifi fan drawn as a dot + three arcs; lit arcs read the signal, and a sweep
// runs inner -> outer while a connect is in flight (replaces the old spinner)
Item {
    id: root

    property int strength: -1   // 0..100, -1 = out of range
    property bool sweeping: false
    property color color: Globals.fgColor
    property real strokeWidth: 1.9
    property real unlitOpacity: 0.16 // arcs above the signal level

    readonly property int level: strength < 0 ? -1 : strength > 80 ? 3 : strength > 55 ? 2 : strength > 30 ? 1 : 0 // NetworkManager's bar cut-offs
    property int sweepStep: 0
    readonly property color hue: Qt.rgba(color.r, color.g, color.b, 1)
    readonly property int litArcs: sweeping ? sweepStep : level

    readonly property var layers: [
        '<circle cx="12" cy="19.6" r="1.4" fill="currentColor" stroke="none"/>',
        '<path d="M8.5 16.4a5 5 0 0 1 7 0"/>',
        '<path d="M5 12.9a10 10 0 0 1 14 0"/>',
        '<path d="M2 8.8a15 15 0 0 1 20 0"/>'
    ]

    implicitWidth: 22
    implicitHeight: 22

    onSweepingChanged: sweepStep = 0

    Repeater {
        model: root.layers

        Image {
            required property string modelData
            required property int index

            anchors.fill: parent
            sourceSize.width: Math.ceil(width)
            sourceSize.height: Math.ceil(height)
            // drawn opaque in the hue, alpha applied through opacity so each arc can fade on its own
            source: "data:image/svg+xml," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="' + root.hue + '" stroke-width="' + root.strokeWidth + '" stroke-linecap="round">' + modelData.replace("currentColor", root.hue) + '</svg>')
            opacity: root.color.a * (index === 0 ? (root.level < 0 && !root.sweeping ? 0.35 : 1) : (index <= root.litArcs ? 1 : root.unlitOpacity))

            Behavior on opacity {
                NumberAnimation {
                    duration: 140
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Timer {
        running: root.sweeping
        interval: 220
        repeat: true
        onTriggered: root.sweepStep = (root.sweepStep + 1) % 4
    }
}
