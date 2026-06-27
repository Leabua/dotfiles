pragma ComponentBehavior: Bound

import Quickshell.Services.Pipewire
import qs.audio
import qs.defaults

import QtQuick
import QtQuick.Layouts

// The audio card body (lives inside AudioMenu's PopupWindow). PipeWire-backed:
//   - output device selector + master output volume + a slider per playing app
//   - input device selector + master input (mic) volume
//   - bottom-left button switches the popup over to the bluetooth card
// Switching default devices uses Pipewire.preferredDefaultAudioSink/Source.
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
        objects: Pipewire.nodes.values
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
            text: "  " + String.fromCodePoint(0xF0F88) // treble clef
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
        devices: root.outputs
        currentNode: root.sink
        currentName: root.devName(root.sink)
        nameFor: n => root.devName(n)
        onSelected: n => Pipewire.preferredDefaultAudioSink = n
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
        icon: (root.source && root.source.audio && (root.source.audio.muted || root.source.audio.volume <= 0)) ? 0xF036D : 0xF036C // mic off / mic
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

    // ----- footer: switch to the bluetooth card -----
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Globals.spacing
        CenterTextBtn {
            id: btSwitch
            icon: String.fromCodePoint(0xF00AF) // bluetooth
            largestButton: btSwitch.implicitHeight // icon-only -> width == height == perfect square
            onClicked: Globals.audioMenuView = "bluetooth"
        }
        Item {
            Layout.fillWidth: true
        } // keep the button hugging the left edge
    }
}
