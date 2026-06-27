import QtQuick
import qs.defaults

// Transient now-playing readout: on a song change, the full "title · artist" marquees
// across the bar once, then clears itself (shell.qml bumps `pulse` to (re)trigger it).
Item {
    id: root
    property string title: ""
    property string artist: ""
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

    Text {
        id: marquee
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
        scrollAnim.restart();
    }

    onPulseChanged: play()
}
