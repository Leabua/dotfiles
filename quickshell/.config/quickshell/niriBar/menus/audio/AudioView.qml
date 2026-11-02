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

    // ----- card-profile devices (HDMI / analog / bluetooth) -----
    // Pipewire only exposes sink / source *nodes* for the profile a card is currently in, and
    // Quickshell's Pipewire binding has no device/profile API. So the other useful profiles are
    // read from pw-dump and switching one is what pavucontrol's Configuration tab does:
    //  - the built-in HDA card flips between "Analog Stereo" and "Digital (HDMI)", so the HDMI
    //    sink doesn't exist while the card sits in its analog profile
    //  - a bluetooth headset in high-fidelity playback (A2DP) has no microphone at all; its mic
    //    only exists in the headset profile (HFP), at call quality
    //  - a connected bluetooth device whose card is "off" has no sink until a profile is picked
    // Once the switch lands, the new node for that card is made the default (claimTimer).

    property var profileOutputs: []
    property var profileInputs: []
    property int pendingCard: -1     // card we switched; its new node becomes the default
    property string pendingClass: "" // "Audio/Sink" | "Audio/Source"
    property var staleNodes: []      // the card's nodes from before the switch; they linger briefly, never claim them

    function cardNode(n, card): bool {
        return n && root.mclass(n) === root.pendingClass && String(n.properties["device.id"]) === String(card);
    }

    // "output:hdmi-stereo+input:analog-stereo" -> "hdmi-stereo"
    function outToken(profile: string): string {
        return profile.indexOf("output:") === 0 ? profile.slice(7).split("+")[0] : "";
    }

    function refreshCards(): void {
        cardsProc.running = true;
    }

    function activateProfile(e): void {
        if (setProfileProc.running)
            return;
        claimTimer.ticks = 0;
        root.pendingCard = e.card;
        root.pendingClass = e.mediaClass;
        root.staleNodes = Pipewire.nodes.values.filter(n => root.cardNode(n, e.card)); // objects, not ids: pipewire reuses ids
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

    // keep availability fresh while open so plugging in HDMI / connecting a headset shows up live
    Timer {
        interval: 4000
        repeat: true
        running: Globals.audioMenuOpen
        onTriggered: root.refreshCards()
    }

    // after a profile switch the new node appears asynchronously; grab it and make it the
    // default (give up after ~5s so we never spin forever)
    Timer {
        id: claimTimer
        interval: 200
        repeat: true
        running: root.pendingCard >= 0
        property int ticks: 0
        onTriggered: {
            const n = Pipewire.nodes.values.find(x => x && x.ready && root.cardNode(x, root.pendingCard) && !root.staleNodes.includes(x));
            if (n) {
                if (root.pendingClass === "Audio/Sink")
                    Pipewire.preferredDefaultAudioSink = n;
                else
                    Pipewire.preferredDefaultAudioSource = n;
            }
            if (n || ++ticks > 25) {
                root.pendingCard = -1;
                root.pendingClass = "";
                ticks = 0;
            }
        }
    }

    Process {
        id: setProfileProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.pendingCard = -1;
                root.pendingClass = "";
            }
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

    function profileEntry(device, profile, mediaClass: string, label: string): var {
        return {
            __profile: true,
            id: "profile:" + device.id + ":" + profile.index,
            card: device.id,
            profile: profile.index,
            mediaClass: mediaClass,
            label: label
        };
    }

    function parseCards(text: string): void {
        let objects;
        try {
            objects = JSON.parse(text);
        } catch (e) {
            return;
        }
        const outs = [];
        const ins = [];
        for (const device of objects) {
            if (device.type !== "PipeWire:Interface:Device" || !device.info)
                continue;
            const cardName = (device.info.props || {})["device.name"] || "";
            if (cardName.startsWith("alsa_card."))
                root.alsaProfiles(device, outs);
            else if (cardName.startsWith("bluez_card."))
                root.bluezProfiles(device, outs, ins);
        }
        root.profileOutputs = outs;
        root.profileInputs = ins;
    }

    // other stereo outputs of a sound card (HDMI while on analog, and back)
    function alsaProfiles(device, outs): void {
        const params = device.info.params || {};
        const active = (params.Profile || [])[0];
        const activeTok = active ? root.outToken(active.name) : "";
        const groups = {}; // output token -> chosen profile (prefer the +input duplex variant)
        for (const p of params.EnumProfile || []) {
            if (!p.name.startsWith("output:") || p.available === "no")
                continue;
            const tok = root.outToken(p.name);
            if (!tok.includes("stereo") || tok === activeTok)
                continue; // skip surround clutter + the profile we're already in
            const prev = groups[tok];
            if (!prev || (p.name.includes("+input") && !prev.name.includes("+input")))
                groups[tok] = p;
        }
        for (const tok in groups)
            outs.push(root.profileEntry(device, groups[tok], "Audio/Sink", groups[tok].description.split(" + ")[0]));
    }

    // bluetooth: offer high-fidelity playback when the card isn't in it, and the headset mic
    // when it isn't in the headset profile; codec variants collapse to the first available
    function bluezProfiles(device, outs, ins): void {
        const params = device.info.params || {};
        const name = (device.info.props || {})["device.description"] || "Bluetooth device";
        const active = ((params.Profile || [])[0] || {}).name || "off";
        const usable = (params.EnumProfile || []).filter(p => p.available !== "no");
        const playback = usable.find(p => p.name.startsWith("a2dp-sink"));
        const headset = usable.find(p => p.name.startsWith("headset-head-unit"));
        if (playback && !active.startsWith("a2dp-sink"))
            outs.push(root.profileEntry(device, playback, "Audio/Sink", name));
        if (headset && !active.startsWith("headset-head-unit"))
            ins.push(root.profileEntry(device, headset, "Audio/Source", name + " mic (call quality)"));
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
            currentName: root.pendingClass === "Audio/Sink" ? "Switching output…" : root.devName(root.sink)
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
            devices: root.inputs.concat(root.profileInputs)
            currentNode: root.source
            currentName: root.pendingClass === "Audio/Source" ? "Switching input…" : root.devName(root.source)
            nameFor: node => node && node.__profile ? node.label : root.devName(node)
            onSelected: node => {
                if (node && node.__profile)
                    root.activateProfile(node);
                else
                    Pipewire.preferredDefaultAudioSource = node;
            }
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
