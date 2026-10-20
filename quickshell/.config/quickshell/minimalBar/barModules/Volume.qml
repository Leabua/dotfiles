import Quickshell.Services.Pipewire
import QtQuick
import qs.templates

BarButton {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int volPercent: ready ? Math.round(sink.audio.volume * 100) : 0

    menu: "audio"
    active: Globals.audioMenuOpen

    PwObjectTracker {
        objects: [root.sink]
    }

    BarValue {
        icon: {
            if (!root.ready || root.muted || root.volPercent === 0)
                return "speakerMuted";
            if (root.volPercent < 34)
                return "speakerLow";
            if (root.volPercent < 67)
                return "speakerMedium";
            return "speaker";
        }
        // muted -> the crossed speaker says it all; a stale percentage would only mislead
        text: root.ready && !root.muted ? root.volPercent + "%" : ""
    }
}
