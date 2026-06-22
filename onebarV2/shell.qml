pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs // home for colours, font etc
import qs.audio
import qs.battery
import qs.sysUtils
import QtQuick
import QtQuick.Layouts // need for rowlayout and colomnLayout

// import Quickshell.Hyprland

Scope {
    id: root
    // Default States of the bar -> level 1 to 3
    property int barLevel: 1
    IpcHandler {
        target: "cycleBarLevel"
        function cycle(): void {
            root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1;
        }
    }
    property bool shouldShowOsd: false

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio
        function onVolumeChanged() {
            root.shouldShowOsd = true;
            osdTimer.restart();
        }
    }

    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.shouldShowOsd = false
    }

    Variants {
        model: Quickshell.screens
        // used for bars panels and overlays
        PanelWindow { // qmllint disable uncreatable-type
            id: shell

            // in charge of making a new bar on any connected screen
            property var modelData
            screen: modelData

            color: "transparent" // this is to make the main bar transparent
            // makes bar go to top
            anchors {
                top: true
                left: true
                right: true
            }

            // makes it float instead of touching anything
            margins { // qmllint disable unresolved-type
                top: 6
                left: 10
                right: 10
                bottom: -3
            }

            // WlrLayershell.exclusiveZone: 24 // Reduced further, bar will partially overlay maximized windows
            // WlrLayershell.layer: WlrLayer.Top // Ensure it renders above windows

            property bool isLocked: false

            // get Hyprland to focus on the bar if its in level 2
            // focusable: root.barLevel > 1

            // need this since quickshell bar with no Height defaults to 0 and looks like it dissappears
            implicitHeight: Math.max(12, island.implicitHeight)
            // simple state engine will go here we basically just want to have a spring effect with no bounce that is purely just going to resize based on island.implicitHeight and implicitWidth
            Rectangle {
                id: island
                color: Globals.bgColor // literally the only time we need a bg in the main bar
                anchors.centerIn: parent
                radius: height / 2
                implicitHeight: contentRoot.implicitHeight + 10 // basically padding of the rectangle from bar elements
                implicitWidth: contentRoot.implicitWidth + 14

                MouseArea {
                    anchors.fill: island
                    anchors.margins: -1 // increase the clickable area a tiny bit over the visible bar
                    cursorShape: Qt.PointingHandCursor // change pointer to pointer finger
                    z: -1 // keep it behind the workspace-dot MouseAreas so clicking a dot still focuses that workspace if workspace clicking is on
                    onDoubleClicked: root.barLevel = root.barLevel >= 3 ? 1 : root.barLevel + 1
                }

                // bar in the middle of parent
                Item {
                    id: contentRoot
                    anchors.centerIn: parent
                    // consider making this assignable to a bind so that we can dyanmically hide the bar with something like Super + shift + Space
                    implicitHeight: colomn.implicitHeight
                    implicitWidth: colomn.implicitWidth

                    opacity: root.shouldShowOsd ? 0 : 1 // -> slider for volume
                    Behavior on opacity {               // animation for transition
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    ColumnLayout {
                        id: colomn
                        anchors.centerIn: parent
                        spacing: 6
                        RowLayout {
                            id: row1
                            spacing: 6
                            // Use shown: false to have it gone forever and true to always have it there
                            Reveal {
                                shown: false
                                Logo {}
                            }
                            Reveal {
                                shown: root.barLevel >= 2
                                Clock {}
                            }
                            Reveal {
                                shown: root.barLevel >= 1
                                Workspaces {}
                            }
                            Reveal {
                                shown: root.barLevel >= 3 || memory.memoryUsage >= 75
                                Memory {
                                    id: memory
                                }
                            }
                            Reveal {
                                shown: root.barLevel >= 3
                                Network {}
                            }
                            Reveal {
                                shown: root.barLevel >= 3
                                CPU {}
                            }
                            Reveal {
                                shown: root.barLevel >= 3
                                Volume {}
                            }
                            Reveal {
                                shown: root.barLevel >= 3 || (battery.percent <= 20 && !battery.isCharging) || (battery.isCharging && battery.percent >= 80)
                                BatteryIcons {
                                    id: battery
                                }
                            }
                            Reveal {
                                shown: root.barLevel >= 3
                                PowerButton {}
                            }
                        }
                    }
                }
                // fading volume OSD
                Item {
                    anchors {
                        fill: parent
                        leftMargin: 7
                        rightMargin: 7
                    }
                    opacity: root.shouldShowOsd ? 1 : 0
                    visible: opacity > 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        spacing: 8

                        Text {
                            text: {
                                var sink = Pipewire.defaultAudioSink;
                                if (!sink || !sink.ready)
                                    return String.fromCodePoint(0xF0581);
                                var v = Math.round(sink.audio.volume * 100);
                                if (sink.audio.muted || v === 0)
                                    return String.fromCodePoint(0xF075F);
                                if (v < 34)
                                    return String.fromCodePoint(0xF057F);
                                if (v < 67)
                                    return String.fromCodePoint(0xF0580);
                                return String.fromCodePoint(0xF057E);
                            }
                            font: Globals.textFont
                            color: Globals.fgColor
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 8
                            radius: implicitHeight * 2
                            color: Qt.alpha(Globals.fgColor, 0.25)

                            Rectangle {
                                anchors {
                                    left: parent.left
                                    top: parent.top
                                    bottom: parent.bottom
                                }
                                width: parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0)
                                radius: parent.radius
                                color: Globals.fgColor
                            }
                        }
                    }
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
}
