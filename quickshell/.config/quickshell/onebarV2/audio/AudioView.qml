pragma ComponentBehavior: Bound

import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.audio
import qs.defaults

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    // fixed card body width so the sliders have a consistent length
    readonly property int menuWidth: 280

    spacing: Globals.spacing

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
    // pick a speaker glyph that matches the current output level / mute state
    function sinkGlyph(): int {
        if (!root.sink || !root.sink.audio || root.sink.audio.muted || root.sink.audio.volume <= 0)
            return 0xF075F; // volume off
        if (root.sink.audio.volume < 0.34)
            return 0xF057F;
        if (root.sink.audio.volume < 0.67)
            return 0xF0580;
        return 0xF057E;
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
    // pactl and switch the card profile on selection (what pavucontrol's Config
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
        root.pendingSinkName = e.sink;
        setProfileProc.command = ["pactl", "set-card-profile", e.card, e.profile];
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
        onExited: root.refreshCards() // the switched-to profile drops out of the list
    }

    Process {
        id: cardsProc
        command: ["pactl", "list", "cards"]
        stdout: StdioCollector {
            onStreamFinished: root.parseCards(text)
        }
    }

    function parseCards(text: string): void {
        const out = [];
        let card = "", path = "", active = "", inProfiles = false;
        let profs = []; 

        const flush = () => {
            if (!card)
                return;
            const activeTok = root.outToken(active);
            const groups = {}; // output token -> chosen profile (prefer the +input duplex variant)
            for (const p of profs) {
                if (p.name.indexOf("output:") !== 0 || p.avail !== "yes")
                    continue;
                const tok = root.outToken(p.name);
                if (!tok.endsWith("-stereo") || tok === activeTok)
                    continue; // skip surround clutter + the profile we're already in
                const prev = groups[tok];
                if (!prev || (p.name.includes("+input") && !prev.name.includes("+input")))
                    groups[tok] = p;
            }
            for (const tok in groups) {
                const p = groups[tok];
                out.push({
                    __profile: true,
                    id: "profile:" + card + ":" + p.name,
                    card: card,
                    profile: p.name,
                    sink: "alsa_output." + path + "." + tok, // predicted node.name pipewire will create
                    label: p.desc.split(" + ")[0] // drop the "+ Analog Stereo Input" tail
                });
            }
        };

        for (const raw of text.split("\n")) {
            const nm = raw.match(/^\tName:\s*(.+)$/);
            if (nm) {
                flush();
                card = nm[1].trim();
                const m = card.match(/^alsa_card\.(.+)$/);
                path = m ? m[1] : "";
                profs = [];
                active = "";
                inProfiles = false;
                continue;
            }
            if (/^\tProfiles:\s*$/.test(raw)) {
                inProfiles = true;
                continue;
            }
            const act = raw.match(/^\tActive Profile:\s*(.+)$/);
            if (act) {
                active = act[1].trim();
                inProfiles = false;
                continue;
            }
            if (/^\t\S/.test(raw)) {
                inProfiles = false; // any other single-tab section ends the Profiles block
                continue;
            }
            if (inProfiles) {
                const pm = raw.match(/^\t\t(\S.*?):\s+(.*)$/);
                if (pm) {
                    const av = pm[2].match(/available:\s*(\w+)/);
                    profs.push({
                        name: pm[1],
                        desc: pm[2].replace(/\s*\([^)]*\)\s*$/, ""), // strip trailing "(sinks: 1, ... available: yes)"
                        avail: av ? av[1] : "unknown"
                    });
                }
            }
        }
        flush();
        root.profileOutputs = out;
    }

    // strut that pins the whole card body to menuWidth (fillWidth children stretch to it)
    Item {
        Layout.preferredWidth: root.menuWidth
        Layout.preferredHeight: 0
    }

    // ----- header -----
    RowLayout {
        Layout.fillWidth: true
        Text {
            text: String.fromCodePoint(0xF0F70) // treble clef
            visible: Globals.headerIcons
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 6
            font.weight: Globals.textFont.weight
        }
        Text {
            Layout.fillWidth: true
            text: "Audio"
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 2
            font.weight: Globals.textFont.weight
        }
    }

    MenuDivider {}

    // ----- output -----
    DeviceSelector {
        Layout.fillWidth: true
        icon: 0xF057E // speaker
        devices: root.outputs.concat(root.profileOutputs) // live sinks + switchable card profiles (HDMI)
        currentNode: root.sink
        currentName: root.devName(root.sink)
        nameFor: n => n && n.__profile ? n.label : root.devName(n)
        onSelected: n => {
            if (n && n.__profile)
                root.activateProfile(n); // switch the card profile, then route to its new sink
            else
                Pipewire.preferredDefaultAudioSink = n;
        }
    }

    // master output volume (the "global" slider that moves everything on this sink)
    VolumeSliderRow {
        Layout.fillWidth: true
        visible: root.sink && root.sink.ready
        icon: root.sinkGlyph()
        value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
        muted: root.sink && root.sink.audio ? root.sink.audio.muted : false
        onMoved: v => {
            if (root.sink && root.sink.audio)
                root.sink.audio.volume = v;
        }
        onIconClicked: {
            if (root.sink && root.sink.audio)
                root.sink.audio.muted = !root.sink.audio.muted;
        }
    }

    // one slider per application currently playing
    Repeater {
        model: root.playbackApps
        delegate: VolumeSliderRow {
            required property var modelData
            Layout.fillWidth: true
            icon: 0xF08C6 // generic application glyph
            value: modelData.audio ? modelData.audio.volume : 0
            muted: modelData.audio ? modelData.audio.muted : false
            onMoved: v => {
                if (modelData.audio)
                    modelData.audio.volume = v;
            }
            onIconClicked: {
                if (modelData.audio)
                    modelData.audio.muted = !modelData.audio.muted;
            }
        }
    }

    MenuDivider {}

    // ----- input -----
    DeviceSelector {
        Layout.fillWidth: true
        Layout.topMargin: Globals.spacing
        icon: 0xF036C // microphone
        devices: root.inputs
        currentNode: root.source
        currentName: root.devName(root.source)
        nameFor: n => root.devName(n)
        onSelected: n => Pipewire.preferredDefaultAudioSource = n
    }

    // master input (mic) volume
    VolumeSliderRow {
        Layout.fillWidth: true
        visible: root.source && root.source.ready
        icon: (root.source && root.source.audio && (root.source.audio.muted || root.source.audio.volume <= 0)) ? 0xF036D : 0xF036C 
        value: root.source && root.source.audio ? root.source.audio.volume : 0
        muted: root.source && root.source.audio ? root.source.audio.muted : false
        onMoved: v => {
            if (root.source && root.source.audio)
                root.source.audio.volume = v;
        }
        onIconClicked: {
            if (root.source && root.source.audio)
                root.source.audio.muted = !root.source.audio.muted;
        }
    }
    //  footer: switch to the bluetooth card (toggle hugs the right edge) 
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Globals.spacing
        Item {
            Layout.fillWidth: true
        } // push the button to the right edge
        ViewSwitchBtn {
            icon: String.fromCodePoint(0xF00AF) // bluetooth
            label: "Bluetooth"
            onClicked: Globals.audioMenuView = "bluetooth"
        }
    }
}
