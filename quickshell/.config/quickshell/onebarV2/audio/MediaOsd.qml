import QtQuick
import qs.defaults

// Transient now-playing readout with two modes, driven by shell.qml:
//   "scroll" -> a song/player change: the full "title · artist" marquees across the bar once.
//   "icon"   -> a play/pause toggle: just the play/pause glyph, centred, for a beat.
// `pulse` is bumped by shell.qml to (re)trigger the animation; scroll emits finished().
Item {
    id: root
    property string title: ""
    property string artist: ""
    property bool playing: false
    property string mode: "icon"   // "icon" | "scroll"
    property int pulse: 0
    signal finished

    anchors {
        fill: parent
        leftMargin: Globals.marginsLeft
        rightMargin: Globals.marginsRight
    }
    clip: true
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: Globals.animDuration
        }
    }

    readonly property string fullText: artist.length ? (title + "   ·   " + artist) : title

    // ----- play / pause icon (centred) -----
    Text {
        anchors.centerIn: parent
        visible: root.mode === "icon"
        text: root.playing ? String.fromCodePoint(0xF040A) : String.fromCodePoint(0xF03E4)
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize + 8
        color: Globals.fgColor
    }

    // ----- scrolling track -----
    Text {
        id: marquee
        visible: root.mode === "scroll"
        anchors.verticalCenter: parent.verticalCenter
        text: root.fullText
        font: Globals.textFont
        color: Globals.fgColor
        x: root.width

        NumberAnimation {
            id: scrollAnim
            target: marquee
            property: "x"
            from: root.width
            to: -marquee.width
            duration: Math.max(3500, (root.width + marquee.width) * 6)
            easing.type: Easing.Linear
            onFinished: root.finished()
        }
    }

    function play(): void {
        if (root.mode === "scroll")
            scrollAnim.restart();
    }

    onPulseChanged: play()
}
