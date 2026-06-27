import QtQuick
import QtQuick.Layouts
import qs.defaults

// Transient now-playing readout. Mirrors VolumeOsd/BrightnessOsd: fills the island,
// fades via opacity, and shell.qml shows it for a beat whenever the track or
// play/pause state changes.
Item {
    id: root
    property string title: ""
    property string artist: ""
    property bool playing: false

    anchors {
        fill: parent
        leftMargin: Globals.marginsLeft
        rightMargin: Globals.marginsRight
    }
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: Globals.animDuration
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Globals.spacing

        Text {
            text: root.playing ? String.fromCodePoint(0xF075A) : String.fromCodePoint(0xF03E4)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 4
            color: Globals.fgColor
        }

        Text {
            Layout.fillWidth: true
            elide: Text.ElideRight
            text: root.artist.length ? (root.title + "  ·  " + root.artist) : root.title
            font: Globals.textFont
            color: Globals.fgColor
        }
    }
}
