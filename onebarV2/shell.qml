pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io // input output lib
import Quickshell.Services.Pipewire //audio
import qs.audio // self explanatory
import qs.defaults // aesthtics and animation
import qs.sysUtils
import QtQuick
import QtQuick.Layouts // need for rowlayout and colomnLayout

// import Quickshell.Hyprland

Scope {
    id: root
    // Default state of the bar -> level 1 to 3
    property int barLevel: 1

    Variants {
        model: Quickshell.screens
        // used for bars panels and overlays
        PanelWindow { // qmllint disable uncreatable-type
            // in charge of making a mirroring the bar on any display
            property var modelData
            screen: modelData

            color: "transparent" // this is to make the main window transparent

            // makes bar go to top
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

            // lets me click the bar
            MouseArea {
                anchors.fill: island
                anchors.margins: -1 // increase the clickable area a tiny bit over the visible bar
                cursorShape: Qt.PointingHandCursor // change arrow to pointer finger
                z: -1 // keep it behind the workspace-dot MouseAreas so clicking a dot still focuses that workspace if workspace clicking is on if workspace clicking is on
                onDoubleClicked: root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1 // doublelick makes it intentional
            }
            // WlrLayershell.exclusiveZone: 24 // Reduced further, bar will partially overlay maximized windows
            // WlrLayershell.layer: WlrLayer.Top // Ensure it renders above windows
            // property bool isLocked: false

            implicitHeight: Math.max(12, island.implicitHeight)

            // like a centered div with a colour and rounding
            Rectangle {
                id: island
                color: Globals.bgColor // literally the only time we need a bg in the main bar
                anchors.centerIn: parent
                implicitHeight: contentRoot.implicitHeight + 10 // basically padding of the rectangle from bar elements
                implicitWidth: contentRoot.implicitWidth + 14
                radius: implicitHeight / 2

                // this is where things are laid out
                Item {
                    id: contentRoot
                    anchors.centerIn: parent
                    // consider making this assignable to a bind so that we can dyanmically hide the bar with something like Super + shift + Space
                    implicitHeight: row1.implicitHeight
                    implicitWidth: row1.implicitWidth

                    ColumnLayout {
                        id: colomn
                        anchors.centerIn: parent
                        spacing: Globals.spacing

                        BarRow1 {                           //all normal bar icons
                            id: row1
                            barLvl: root.barLevel
                        }
                    }

                    opacity: root.activeOsd !== "" ? 0 : 1

                    Behavior on opacity {               // animation for transition
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
                // fading volume OSD
                VolumeOsd {
                    sliderHeight: island.implicitHeight
                    opacity: root.activeOsd === "volume" ? 1 : 0
                }
                BrightnessOsd {
                    id: brightnessOsd
                    sliderHeight: island.implicitHeight
                    opacity: root.activeOsd === "brightness" ? 1 : 0
                    brightness: root.brightness
                    maxBrightness: root.maxBrightness
                }
                // in shell.qml, add alongside your existing Scope children
                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }
        // FloatingWindow {
        // anchors.centerIn
        // }
    }

    LazyLoader {
        source: "notifications/Notifications.qml"
        active: true
    }
    property string activeOsd: "" // "volume" | "brightness" | ""

    // one shared timer
    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.activeOsd = ""
    }

    // read max once on startup, never again
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
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }
    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            root.activeOsd = "volume";
            osdTimer.restart();
        }
    }

    //////////////////////////////////////////////
    // IPC Handlers -> use these targets to set your binds in Hyprland
    // Using something like bind("SUPER + ALT+ SPACE", hl.dsp.exec_cmd("qs -p $HOME/.config/quickshell/onebarV2 ipc call cycleBarLevel cycle")) - to toggle the bar state
    //////////////////////////////////////////////
    IpcHandler {
        target: "cycleBarLevel"
        function cycle(): void {
            root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1;
        }
    }
}
