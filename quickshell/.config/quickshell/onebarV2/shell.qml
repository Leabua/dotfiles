pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.audio
import qs.defaults
import qs.launcher // installs the qs.launcher module so Launcher.qml can resolve its sibling components (SearchInput/ResultList)
import qs.sysUtils
import qs.wifi // installs the qs.wifi module so WifiMenu.qml can resolve WifiView/WifiNetworkRow
import QtQuick

Scope {
    id: root
    property int barLevel: 1
    property bool barShown: true // toggled via the "bar" IPC handler; bar level is remembered

    property bool windowVisible: true

    // both phases derive from one Globals knob -> tune the whole toggle in one place
    readonly property int collapseShrink: Globals.barCollapse // scale phase
    readonly property int collapseFade: Math.round(Globals.barCollapse * 0.4) // content fade phase

    onBarShownChanged: {
        if (barShown) {
            hideWindowTimer.stop();
            windowVisible = true; // map the window before animating open
        } else {
            windowVisible = true; // stay mapped through the collapse...
            hideWindowTimer.restart(); // ...then unmap once it finishes
        }
    }

    Timer {
        id: hideWindowTimer
        interval: root.collapseFade + root.collapseShrink + 30 // just after the collapse finishes
        onTriggered: root.windowVisible = false
    }

    Variants {
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            property var modelData
            screen: modelData

            visible: root.windowVisible // unmapped once collapsed -> no reserved space

            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            margins { // qmllint disable unresolved-type
                top: Globals.marginsTop
                left: Globals.marginsLeft
                right: Globals.marginsRight
                bottom: Globals.marginsBottom
            }

            MouseArea {
                anchors.fill: island
                anchors.margins: -1
                cursorShape: Qt.PointingHandCursor
                z: -1
                enabled: root.barShown // don't cycle levels while collapsed to a dot
                onDoubleClicked: root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1
            }

            implicitHeight: Math.max(1, island.implicitHeight)

            Binding {
                target: Globals
                property: "currentBarHeight"   // correct capital H
                value: island.implicitHeight
            }

            // mirror bar visibility so centered menus can shift up when it hides
            Binding {
                target: Globals
                property: "barShown"
                value: root.barShown
            }

            Rectangle {
                id: island
                color: Globals.bgColor
                anchors.centerIn: parent

                // Drive island height from a dedicated Text that is always instantiated but hidden so I dont get any weird sizing issues
                Text {
                    id: heightAnchor
                    visible: false
                    font: Globals.textFont
                    text: "Wg"
                }

                implicitHeight: heightAnchor.implicitHeight + 8
                implicitWidth: contentRoot.implicitWidth + 14
                radius: implicitHeight / 2

                Item {
                    id: contentRoot
                    anchors.centerIn: parent
                    implicitHeight: row1.implicitHeight
                    implicitWidth: row1.implicitWidth

                    BarRow1 {
                        id: row1
                        barLvl: root.barLevel
                    }

                    opacity: root.activeOsd !== "" ? 0 : 1

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }

                VolumeOsd {
                    sliderHeight: island.implicitHeight
                    opacity: (root.barShown && root.activeOsd === "volume") ? 1 : 0
                    volPercent: root.volPercent
                    muted: root.volMuted
                }
                BrightnessOsd {
                    id: brightnessOsd
                    sliderHeight: island.implicitHeight
                    opacity: (root.barShown && root.activeOsd === "brightness") ? 1 : 0
                    brightness: root.brightness
                    maxBrightness: root.maxBrightness
                }
                MediaOsd {
                    opacity: (root.barShown && (root.activeOsd === "mediaScroll" || root.activeOsd === "mediaIcon")) ? 1 : 0
                    mode: root.activeOsd === "mediaIcon" ? "icon" : "scroll"
                    pulse: root.mediaPulse
                    title: root.mediaPlayer ? root.mediaPlayer.trackTitle : ""
                    artist: root.mediaPlayer ? root.mediaPlayer.trackArtist : ""
                    playing: root.mediaPlayer ? root.mediaPlayer.isPlaying : false
                    onFinished: if (root.activeOsd === "mediaScroll")
                        root.activeOsd = ""
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }

                // ----- show/hide collapse animation (IPC: target "bar") -----
                states: State {
                    name: "hidden"
                    when: !root.barShown
                    PropertyChanges {
                        target: island
                        scale: 0
                    }
                    PropertyChanges {
                        target: contentRoot
                        opacity: 0
                    }
                }

                transitions: [
                    Transition {
                        to: "hidden"
                        SequentialAnimation {
                            NumberAnimation {
                                target: contentRoot
                                property: "opacity"
                                duration: root.collapseFade
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: island
                                property: "scale"
                                duration: root.collapseShrink
                                easing.type: Easing.InOutCubic
                            }
                        }
                    },
                    Transition {
                        from: "hidden"
                        SequentialAnimation {
                            NumberAnimation {
                                target: island
                                property: "scale"
                                from: 0
                                duration: root.collapseShrink
                                easing.type: Easing.InOutCubic
                            }
                            NumberAnimation {
                                target: contentRoot
                                property: "opacity"
                                duration: root.collapseFade
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                ]
            }
        }
    }

    LazyLoader {
        source: "notifications/Notifications.qml"
        active: true
    }
    LazyLoader {
        source: "power/PowerMenu.qml"
        active: true
    }
    LazyLoader {
        source: "battery/PowerProfiles.qml"
        active: true
    }
    LazyLoader {
        source: "audio/AudioMenu.qml"
        active: true
    }
    LazyLoader {
        source: "wifi/WifiMenu.qml"
        active: true
    }
    LazyLoader {
        source: "clipboard/Clipboard.qml"
        active: true
    }
    LazyLoader {
        source: "launcher/Launcher.qml"
        active: true
    }

    property string activeOsd: ""

    Timer {
        id: osdTimer
        interval: 1000
        onTriggered: root.activeOsd = ""
    }

    Process {
        command: ["brightnessctl", "max"]
        stdout: SplitParser {
            onRead: data => root.maxBrightness = parseInt(data.trim())
        }
        Component.onCompleted: running = true
    }

    property int brightness: 0
    property int maxBrightness: 1

    Process {
        id: brightnessProc
        command: ["brightnessctl", "get"]
        stdout: SplitParser {
            onRead: data => root.brightness = parseInt(data.trim())
        }
    }
    Process {
        command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                if (!data.includes("backlight"))
                    return;
                brightnessProc.running = true;
                root.activeOsd = "brightness";
                osdTimer.restart();
            }
        }
    }

    property int volPercent: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) : 0
    property bool volMuted: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio ? Pipewire.defaultAudioSink.audio.muted : false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        ignoreUnknownSignals: true

        function onVolumeChanged() {
            root.activeOsd = "volume";
            osdTimer.restart();
        }

        function onMutedChanged() {
            root.activeOsd = "volume";
            osdTimer.restart();
        }
    }
    // ----- media OSD: flash track + play/pause like the volume/brightness OSDs -----
    // pick the playing MPRIS player, else the first one available
    readonly property var mediaPlayer: {
        const ps = Mpris.players ? Mpris.players.values : [];
        if (!ps || ps.length === 0)
            return null;
        for (const p of ps)
            if (p.isPlaying)
                return p;
        return ps[0];
    }

    // don't flash the OSD for the property values that settle in on launch/reload
    property bool mediaArmed: false
    Timer {
        interval: 1500
        running: true
        onTriggered: root.mediaArmed = true
    }

    // bumped on every media event -> tells MediaOsd to (re)start its animation
    property int mediaPulse: 0
    property double lastTrackChange: 0

    // play/pause icon flash gets a fixed window; the scroll clears itself via onFinished
    Timer {
        id: mediaIconTimer
        interval: 1500
        onTriggered: if (root.activeOsd === "mediaIcon")
            root.activeOsd = ""
    }

    // a song / player change -> marquee the full track across the bar
    function flashTrack(): void {
        if (!root.mediaArmed || !root.mediaPlayer || !root.mediaPlayer.trackTitle)
            return;
        root.lastTrackChange = Date.now();
        root.activeOsd = "mediaScroll";
        root.mediaPulse++;
    }

    // a play/pause toggle -> just the centred icon for a beat (skip if it rode in on a track change)
    function flashToggle(): void {
        if (!root.mediaArmed || !root.mediaPlayer)
            return;
        if (Date.now() - root.lastTrackChange < 500)
            return;
        root.activeOsd = "mediaIcon";
        root.mediaPulse++;
        mediaIconTimer.restart();
    }

    Connections {
        target: root.mediaPlayer
        ignoreUnknownSignals: true
        function onTrackTitleChanged() {
            root.flashTrack();
        }
        function onTrackArtistChanged() {
            root.flashTrack();
        }
        function onPlaybackStateChanged() {
            root.flashToggle();
        }
    }

    IpcHandler {
        target: "cycleBarLevel"
        function cycle(): void {
            root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1;
        }
    }

    // toggle the whole bar visible/hidden with the collapse animation
    IpcHandler {
        target: "bar"
        function toggle(): void {
            root.barShown = !root.barShown;
        }
        function show(): void {
            root.barShown = true;
        }
        function hide(): void {
            root.barShown = false;
        }
    }
}
