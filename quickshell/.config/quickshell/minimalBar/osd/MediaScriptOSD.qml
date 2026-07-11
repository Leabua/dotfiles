pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.templates
import qs.osd

RowLayout {
    id: root
    spacing: Globals.spacing / 3

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

    Text {
        text: {
            if (!root.player)
                return "";
            return root.player.trackArtist ? root.player.trackArtist + " - " + root.player.trackTitle : root.player.trackTitle;
        }
        font: Globals.textFont
        color: Globals.fgColor
        opacity: root.playing ? 1 : 0.4 // paused -> dimmed, like waybar
        elide: Text.ElideRight
        Layout.maximumWidth: OsdState.fixedWidth
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
