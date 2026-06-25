pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.audio
import qs.defaults
import qs.sysUtils
import QtQuick

Scope {
    id: root
    property int barLevel: 1

    Variants {
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            property var modelData
            screen: modelData

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
                onDoubleClicked: root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1
            }

            implicitHeight: Math.max(1, island.implicitHeight)

            Binding {
                target: Globals
                property: "currentBarHeight"   // correct capital H
                value: island.implicitHeight
            }

            Rectangle {
                id: island
                color: Globals.bgColor
                anchors.centerIn: parent

                // Drive island height from a dedicated Text that is always
                // instantiated and always uses Globals.textFont, completely independent
                // of RowLayout's internal visible-children calculation.
                Text {
                    id: heightAnchor
                    visible: false
                    font: Globals.textFont
                    text: "Wg" // W = widest, g = deepest descender → reliable full line height -> otherwise hidden elements may create additional pixels causing window to shift
                }

                implicitHeight: heightAnchor.implicitHeight + 10
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
                    opacity: root.activeOsd === "volume" ? 1 : 0
                }
                BrightnessOsd {
                    id: brightnessOsd
                    sliderHeight: island.implicitHeight
                    opacity: root.activeOsd === "brightness" ? 1 : 0
                    brightness: root.brightness
                    maxBrightness: root.maxBrightness
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
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

    property string activeOsd: ""

    Timer {
        id: osdTimer
        interval: 1500
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

    // todo Getting rid of the volume slider showing on startup
    // 1. Create a boot flag and a timer to turn it off after 1.5 seconds
    property bool isBooting: true
    Timer {
        interval: 1500
        running: true
        onTriggered: root.isBooting = false
    }

    // 2. The tracking block
    property var currentVolume: Pipewire.defaultAudioSink?.audio?.volume
    onCurrentVolumeChanged: {
        // 3. Only show the OSD if we are NOT booting
        if (!isBooting && currentVolume !== undefined && root.barLevel) {
            root.activeOsd = "volume";
            osdTimer.restart();
        }
    }

    IpcHandler {
        target: "cycleBarLevel"
        function cycle(): void {
            root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1;
        }
    }
}
