pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

// central state for the left island osds -> extracted from onebarV2 shell.qml

Singleton {
    id: root

    property string active: ""

    // one shared width so the sliders dont resize the island while swapping
    readonly property int fixedWidth: 280

    function show(name) {
        active = name;
        osdTimer.restart();
    }

    Timer {
        id: osdTimer
        interval: 1000
        onTriggered: root.active = ""
    }

    // ------- volume (from onebarV2 shell.qml) -------
    readonly property int volPercent: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
    readonly property bool volMuted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio.muted : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            root.show("volume");
        }

        function onMutedChanged() {
            root.show("volume");
        }
    }

    // ------- brightness (from onebarV2 shell.qml) -------
    property int brightness: 0
    property int maxBrightness: 1
    readonly property int brightPercent: maxBrightness > 0 ? Math.round(brightness / maxBrightness * 100) : 0

    Process {
        command: ["brightnessctl", "max"]
        stdout: SplitParser {
            onRead: data => root.maxBrightness = parseInt(data.trim())
        }
        Component.onCompleted: running = true
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "get"]
        stdout: SplitParser {
            onRead: data => root.brightness = parseInt(data.trim())
        }
        Component.onCompleted: running = true // seed the value so the first flash isnt 0
    }

    // backlight events have no dbus signal -> watch udev like onebarV2 did
    Process {
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!data.includes("backlight"))
                    return;
                brightnessProc.running = true;
                root.show("brightness");
            }
        }
    }
}
