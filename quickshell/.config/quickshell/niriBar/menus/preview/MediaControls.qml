import QtQuick
import QtQuick.Layouts
import QtMultimedia
import qs.templates
import qs.menus.preview

// transport for the preview's MediaPlayer: play / pause, ±10 s, scrubber, volume
RowLayout {
    id: root

    required property MediaPlayer player
    required property AudioOutput audio

    readonly property bool playing: player.playbackState === MediaPlayer.PlayingState

    function clock(ms: real): string {
        const total = Math.max(0, Math.floor(ms / 1000));
        const h = Math.floor(total / 3600);
        const m = Math.floor(total / 60) % 60;
        const s = String(total % 60).padStart(2, "0");
        return h > 0 ? h + ":" + String(m).padStart(2, "0") + ":" + s : m + ":" + s;
    }

    function togglePlay(): void {
        if (playing)
            player.pause();
        else
            player.play();
    }

    function seekBy(ms: real): void {
        if (player.seekable)
            player.setPosition(Math.max(0, Math.min(player.duration, player.position + ms)));
    }

    function nudgeVolume(delta: real): void {
        audio.muted = false;
        audio.volume = Math.max(0, Math.min(1, audio.volume + delta));
    }

    Layout.fillWidth: true
    spacing: 4

    TransportButton {
        icon: root.playing ? "pause" : "play"
        primary: true
        size: 40
        onClicked: root.togglePlay()
    }
    TransportButton {
        Layout.leftMargin: 4
        icon: "back10"
        iconSize: 20
        enabled: root.player.seekable
        onClicked: root.seekBy(-10000)
    }
    TransportButton {
        icon: "forward10"
        iconSize: 20
        enabled: root.player.seekable
        onClicked: root.seekBy(10000)
    }

    Text {
        Layout.leftMargin: 8
        text: root.clock(root.player.position)
        color: Qt.alpha(Globals.fgColor, 0.55)
        font.family: Globals.textFont.family
        font.pixelSize: 13
        font.features: { "tnum": 1 }
    }

    PreviewSlider {
        id: seek
        Layout.fillWidth: true
        Layout.leftMargin: 6
        Layout.rightMargin: 6
        from: 0
        to: Math.max(1, root.player.duration)
        enabled: root.player.seekable
        onMoved: root.player.setPosition(value)

        // follow playback, except while the handle is held
        Binding on value {
            when: !seek.pressed
            value: root.player.position
        }
    }

    Text {
        text: root.clock(root.player.duration)
        color: Qt.alpha(Globals.fgColor, 0.55)
        font.family: Globals.textFont.family
        font.pixelSize: 13
        font.features: { "tnum": 1 }
    }

    TransportButton {
        Layout.leftMargin: 10
        icon: root.audio.muted || root.audio.volume <= 0 ? "speakerMuted" : root.audio.volume < 0.34 ? "speakerLow" : root.audio.volume < 0.67 ? "speakerMedium" : "speaker"
        onClicked: root.audio.muted = !root.audio.muted
    }

    PreviewSlider {
        Layout.preferredWidth: 96
        from: 0
        to: 1
        value: root.audio.volume
        dimmed: root.audio.muted
        onMoved: {
            root.audio.muted = false;
            root.audio.volume = value;
        }
    }
}
