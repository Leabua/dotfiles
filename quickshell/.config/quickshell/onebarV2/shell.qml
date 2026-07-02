pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import qs.audio
import qs.defaults
import qs.launcher
import qs.reminders
import qs.sysUtils
import qs.wifi
import QtQuick

Scope {
    id: root
    property int barLevel: 1
    property bool barShown: true

    property bool windowVisible: true

    readonly property int collapseShrink: Globals.barCollapse  //scale
    readonly property int collapseFade: Math.round(Globals.barCollapse * 0.4) // content fade 

    onBarShownChanged: {
        if (barShown) {
            hideWindowTimer.stop();
            windowVisible = true;
        } else {
            windowVisible = true;
            hideWindowTimer.restart();
        }
    }

    Timer {
        id: hideWindowTimer
        interval: root.collapseFade + root.collapseShrink + 30
        onTriggered: root.windowVisible = false
    }

    Variants {
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            property var modelData
            screen: modelData

            visible: root.windowVisible

            color: "transparent"

            anchors {
                top: true
                left: true
                right: true
            }

            margins {
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
                enabled: root.barShown
                onDoubleClicked: root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1
            }

            implicitHeight: Math.max(1, island.implicitHeight)

            // to toggle bar hide bar on wayland
            Binding {
                target: Globals
                property: "currentBarHeight"
                value: island.implicitHeight
            }

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
                    opacity: (root.barShown && root.activeOsd === "media") ? 1 : 0
                    pulse: root.mediaPulse
                    title: root.activeMediaPlayer ? root.activeMediaPlayer.trackTitle : ""
                    artist: root.activeMediaPlayer ? root.activeMediaPlayer.trackArtist : ""
                    onFinished: if (root.activeOsd === "media")
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
        source: "battery/BatteryWarnings.qml" // single-instance low-battery notifier (fires once, not per-screen)
        active: true
    }
    LazyLoader {
        source: "reminders/Reminders.qml"
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
    // ----- media OSD: marquee the track whenever a song changes -----
    // we watch every MPRIS player and react to whichever one's track actually changes,
    // so changing a song in (say) the Apple Music tab surfaces that track, not a
    // background YouTube video that didn't change.
    property var activeMediaPlayer: null
    property int mediaPulse: 0

    property bool mediaArmed: false
    Timer {
        interval: 1500
        running: true
        onTriggered: root.mediaArmed = true
    }

    function flashTrack(player): void {
        if (!root.mediaArmed || !player || !player.trackTitle)
            return;
        root.activeMediaPlayer = player;
        root.activeOsd = "media";
        root.mediaPulse++;
    }

    Instantiator {
        model: Mpris.players
        delegate: QtObject {
            id: watcher
            required property var modelData
            readonly property string key: (modelData && modelData.trackTitle ? modelData.trackTitle : "") + "" + (modelData && modelData.trackArtist ? modelData.trackArtist : "")
            property string lastKey: ""
            onKeyChanged: {
                if (key === lastKey || key === "")
                    return;
                lastKey = key;
                root.flashTrack(modelData);
            }
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
