pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.menus.audio
import qs.templates

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property int availableWidth: 360
    readonly property int menuWidth: Math.min(360, availableWidth)

    width: root.menuWidth
    spacing: 16

    // ----- pipewire helpers -----
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    function mclass(n): string {
        return n && n.properties ? (n.properties["media.class"] || "") : "";
    }
    function isOutput(n): bool {
        return root.mclass(n) === "Audio/Sink";
    }
    function isInput(n): bool {
        return root.mclass(n) === "Audio/Source" && !(n.name || "").includes("monitor");
    }
    function isPlayback(n): bool {
        return root.mclass(n) === "Stream/Output/Audio";
    }
    function devName(n): string {
        return n ? (n.description || n.nickname || n.name || "Unknown") : "";
    }
    function appName(n): string {
        if (!n || !n.properties)
            return "Application";
        return n.properties["application.name"] || n.properties["media.name"] || n.description || n.name || "Application";
    }

    // resolve the playback app's real icon so a row shows *what* is playing.
    // the stream's own application.

    function appIcon(n): string {
        if (!n || !n.properties)
            return "";
        const p = n.properties;
        for (const cand of [p["application.name"], p["application.process.binary"], n.name]) {
            if (!cand)
                continue;
            const e = DesktopEntries.heuristicLookup(cand);
            if (e && e.icon) {
                const path = Quickshell.iconPath(e.icon, "");
                if (path)
                    return path;
            }
        }
        const ico = p["application.icon-name"];
        return ico ? Quickshell.iconPath(ico, "") : "";
    }
    readonly property var outputs: Pipewire.nodes.values.filter(n => root.isOutput(n))
    readonly property var inputs: Pipewire.nodes.values.filter(n => root.isInput(n))
    readonly property var playbackApps: Pipewire.nodes.values.filter(n => root.isPlayback(n))

    // keep every node we bind to alive + ready so audio.volume reads/writes work
    PwObjectTracker {
        objects: Globals.audioMenuOpen ? Pipewire.nodes.values : [] // only track nodes while the card is open
    }

    // ----- card-profile outputs (HDMI / analog) -----
    // Pipewire only exposes a sink *node* for the profile a card is currently in:
    // the built-in HDA card flips between "Analog Stereo" and "Digital (HDMI)"
    // profiles, so the HDMI sink simply doesn't exist while the card sits in its
    // analog profile -- which is why HDMI never showed up here (USB cards expose a
    // standalone sink and so always do). Quickshell's Pipewire binding has no
    // device/profile API, so we surface the *other* available output profiles via
    // pw-dump and switch the card profile on selection (what pavucontrol's Config
    // tab does), then route the default sink to the node it creates.

    property var profileOutputs: []
    property string pendingSinkName: "" // sink we expect to appear after a profile switch

    // "output:hdmi-stereo+input:analog-stereo" -> "hdmi-stereo"
    function outToken(profile: string): string {
        return profile.indexOf("output:") === 0 ? profile.slice(7).split("+")[0] : "";
    }

    function refreshCards(): void {
        cardsProc.running = true;
    }

    // flip the card to the profile behind this entry; once its sink node shows up
    // (claimTimer) we make it the default so audio actually follows
    function activateProfile(e): void {
        if (setProfileProc.running)
            return;
        claimTimer.ticks = 0;
        root.pendingSinkName = e.sink;
        setProfileProc.command = ["wpctl", "set-profile", String(e.card), String(e.profile)];
        setProfileProc.running = true;
    }

    Component.onCompleted: if (Globals.audioMenuOpen)
        root.refreshCards()

    Connections {
        target: Globals
        function onAudioMenuOpenChanged(): void {
            if (Globals.audioMenuOpen)
                root.refreshCards();
        }
    }

    // keep availability fresh while open so plugging in HDMI shows up live
    Timer {
        interval: 4000
        repeat: true
        running: Globals.audioMenuOpen
        onTriggered: root.refreshCards()
    }

    // after a profile switch the new sink appears asynchronously; grab it and
    // make it default (give up after ~5s so we never spin forever)

    Timer {
        id: claimTimer
        interval: 200
        repeat: true
        running: root.pendingSinkName !== ""
        property int ticks: 0
        onTriggered: {
            const n = Pipewire.nodes.values.find(x => x && x.name === root.pendingSinkName);
            if (n && n.ready) {
                Pipewire.preferredDefaultAudioSink = n;
                root.pendingSinkName = "";
                ticks = 0;
            } else if (++ticks > 25) {
                root.pendingSinkName = "";
                ticks = 0;
            }
        }
    }

    Process {
        id: setProfileProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.pendingSinkName = "";
            root.refreshCards();
        }
    }

    Process {
        id: cardsProc
        command: ["pw-dump"]
        stdout: StdioCollector {
            onStreamFinished: root.parseCards(text)
        }
    }

    function parseCards(text: string): void {
        const out = [];
        let objects;
        try {
            objects = JSON.parse(text);
        } catch (e) {
            return;
        }
        for (const device of objects) {
            if (device.type !== "PipeWire:Interface:Device" || !device.info)
                continue;
            const props = device.info.props || {};
            const cardName = props["device.name"] || "";
            if (!cardName.startsWith("alsa_card."))
                continue;
            const path = cardName.slice(10);
            const params = device.info.params || {};
            const profiles = params.EnumProfile || [];
            const active = (params.Profile || [])[0];
            const activeTok = active ? root.outToken(active.name) : "";
            const groups = {}; // output token -> chosen profile (prefer the +input duplex variant)
            for (const p of profiles) {
                if (!p.name.startsWith("output:") || p.available === "no")
                    continue;
                const tok = root.outToken(p.name);
                if (!tok.includes("stereo") || tok === activeTok)
                    continue; // skip surround clutter + the profile we're already in
                const prev = groups[tok];
                if (!prev || (p.name.includes("+input") && !prev.name.includes("+input")))
                    groups[tok] = p;
            }
            for (const tok in groups) {
                const p = groups[tok];
                out.push({
                    __profile: true,
                    id: "profile:" + device.id + ":" + p.index,
                    card: device.id,
                    profile: p.index,
                    sink: "alsa_output." + path + "." + tok,
                    label: p.description.split(" + ")[0]
                });
            }
        }
        root.profileOutputs = out;
    }

    MenuHeader {
        title: "Audio"
        icon: "speaker"
        actionText: "Bluetooth"
        actionIcon: "bluetooth"
        onActionClicked: Globals.audioMenuView = "bluetooth"
        onCloseRequested: Globals.audioMenuOpen = false
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        DeviceSelector {
            label: "Output"
            iconName: "speaker"
            devices: root.outputs.concat(root.profileOutputs)
            currentNode: root.sink
            currentName: root.pendingSinkName !== "" ? "Switching output…" : root.devName(root.sink)
            nameFor: node => node && node.__profile ? node.label : root.devName(node)
            onSelected: node => {
                if (node && node.__profile)
                    root.activateProfile(node);
                else
                    Pipewire.preferredDefaultAudioSink = node;
            }
        }

        VolumeSliderRow {
            visible: root.sink && root.sink.ready
            iconName: "speaker"
            value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
            muted: root.sink && root.sink.audio ? root.sink.audio.muted : false
            onMoved: value => {
                if (root.sink && root.sink.audio)
                    root.sink.audio.volume = value;
            }
            onIconClicked: {
                if (root.sink && root.sink.audio)
                    root.sink.audio.muted = !root.sink.audio.muted;
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.playbackApps.length > 0
        spacing: 8

        MenuSectionLabel {
            text: "Applications"
        }

        Repeater {
            model: root.playbackApps

            delegate: VolumeSliderRow {
                required property var modelData
                label: root.appName(modelData)
                iconSource: root.appIcon(modelData)
                iconName: "speaker"
                value: modelData.audio ? modelData.audio.volume : 0
                muted: modelData.audio ? modelData.audio.muted : false
                onMoved: value => {
                    if (modelData.audio)
                        modelData.audio.volume = value;
                }
                onIconClicked: {
                    if (modelData.audio)
                        modelData.audio.muted = !modelData.audio.muted;
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        DeviceSelector {
            label: "Input"
            iconName: "microphone"
            devices: root.inputs
            currentNode: root.source
            currentName: root.devName(root.source)
            nameFor: node => root.devName(node)
            onSelected: node => Pipewire.preferredDefaultAudioSource = node
        }

        VolumeSliderRow {
            visible: root.source && root.source.ready
            iconName: "microphone"
            value: root.source && root.source.audio ? root.source.audio.volume : 0
            muted: root.source && root.source.audio ? root.source.audio.muted : false
            onMoved: value => {
                if (root.source && root.source.audio)
                    root.source.audio.volume = value;
            }
            onIconClicked: {
                if (root.source && root.source.audio)
                    root.source.audio.muted = !root.source.audio.muted;
            }
        }
    }
}
