pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

StatusButton {
    id: audioBtn

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [audioBtn.defaultSink]
    }

    isActive: defaultSink && defaultSink.audio && !defaultSink.audio.muted
    invertWhenOff: false

    icon: {
        if (!defaultSink || !defaultSink.audio) return "󰕿";
        if (defaultSink.audio.muted) return "󰝟";
        let vol = Math.round(defaultSink.audio.volume * 100);
        if (vol >= 50) return "󰕾";
        return "󰖀";
    }

    label: {
        if (!defaultSink || !defaultSink.audio) return "";
        let vol = Math.round(defaultSink.audio.volume * 100);
        return vol + "%";
    }
}
