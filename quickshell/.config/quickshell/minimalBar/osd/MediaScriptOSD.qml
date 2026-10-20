pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.templates
import qs.osd

RowLayout {
    id: root
    spacing: Globals.spacing
    Layout.maximumWidth: OsdState.fixedWidth
    opacity: root.playing ? 1 : 0.45 // paused -> the whole line steps back

    // last player that emitted an event -> mirrors `playerctl --all-players --follow`
    property var lastPlayer: null

    readonly property var player: {
        const valid = p => p && (p.playbackState === MprisPlaybackState.Playing || p.playbackState === MprisPlaybackState.Paused);
        if (valid(lastPlayer))
            return lastPlayer;
        const players = Mpris.players.values;
        return players.find(p => p.playbackState === MprisPlaybackState.Playing) ?? players.find(p => p.playbackState === MprisPlaybackState.Paused) ?? null;
    }
    readonly property bool playing: player !== null && player.playbackState === MprisPlaybackState.Playing

    visible: OsdState.active === "" && player !== null // only show if volume or brightness is not being shown AND the player has something.

    // title leads, artist sits a tier quieter -> hierarchy instead of an "artist - title" string
    Text {
        Layout.fillWidth: true
        Layout.maximumWidth: implicitWidth
        text: root.player ? root.player.trackTitle : ""
        textFormat: Text.PlainText
        font: Globals.barFont
        color: Globals.fgColor
        elide: Text.ElideRight
    }

    Text {
        visible: text !== ""
        Layout.fillWidth: true
        Layout.maximumWidth: implicitWidth
        text: root.player ? root.player.trackArtist : ""
        textFormat: Text.PlainText
        font.family: Globals.barFont.family
        font.pixelSize: Globals.barFont.pixelSize
        font.weight: Font.Medium
        color: Qt.alpha(Globals.fgColor, 0.55)
        elide: Text.ElideRight
    }

    // one silent watcher per player so status/track events pick the shown player
    Instantiator {
        model: Mpris.players
        delegate: QtObject {
            required property var modelData
            readonly property string key: modelData ? modelData.trackTitle + "|" + modelData.trackArtist + "|" + modelData.playbackState : ""
            onKeyChanged: {
                if (key !== "")
                    root.lastPlayer = modelData;
            }
            // a player that closes never emits a final state change -> drop the
            // stale reference so the island hides instead of showing a dead track
            Component.onDestruction: {
                if (root.lastPlayer === modelData)
                    root.lastPlayer = null;
            }
        }
    }
}
