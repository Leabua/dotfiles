pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.menus.engineRoom
import qs.menus.system
import qs.templates
import QtQuick
import QtQuick.Layouts

// niri: everything the old right island held, on one card behind a single bar pill (barModules/SystemStatus).
// Top: the full engine room readout (cpu + cores, gpu, memory, battery). Below: a row of tiles -> power profiles
// and audio (each showing its current state, each opening its full menu) and the keep awake toggle
Scope {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool sinkReady: sink !== null && sink.ready

    PwObjectTracker {
        objects: [root.sink]
    }

    IpcHandler {
        target: "systemMenu"
        function toggle(): void { Globals.toggleMenu("system"); }
        function show(): void { if (!Globals.systemMenuOpen) Globals.toggleMenu("system"); }
        function hide(): void { Globals.systemMenuOpen = false; }
    }

    // ------- current power profile, shown on its row -------
    property string activeProfile: ""
    readonly property var profiles: [
        { name: "power-saver", label: "Power saver", icon: "leaf" },
        { name: "balanced", label: "Balanced", icon: "balanced" },
        { name: "performance", label: "Performance", icon: "bolt" }
    ]

    Process {
        id: getProfileCmd
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: root.activeProfile = text.trim()
        }
    }
    Timer {
        interval: 2000
        running: Globals.systemMenuOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: getProfileCmd.running = true
    }

    PopupWindow {
        id: popup
        open: Globals.systemMenuOpen
        onDismissed: Globals.systemMenuOpen = false
        hAlign: "center"
        anchorCenterX: Globals.menuAnchorX // beside the pill that toggled it
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: 16
        backgroundColor: Globals.bgColor

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        ColumnLayout {
            width: Math.min(680, popup.availableWidth)
            spacing: 20

            MenuHeader {
                title: "System"
                icon: "activity"
                onCloseRequested: Globals.systemMenuOpen = false
            }

            // only built while open -> the engine room samples (and spawns its gpu / temp probes) only while seen
            Loader {
                Layout.fillWidth: true
                active: Globals.systemMenuOpen
                sourceComponent: EngineView {
                    availableWidth: popup.availableWidth
                    live: Globals.systemMenuOpen
                    showHeader: false
                }
            }

            // ------- quick tiles -> the two with chevrons swap this card for that menu, opened beside the same pill -------
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 8
                rowSpacing: 8

                SystemTile {
                    text: "Power profiles"
                    icon: "bolt"
                    detail: root.profiles.find(p => p.name === root.activeProfile)?.label ?? ""
                    opensMenu: true
                    onClicked: Globals.toggleMenu("powerProfiles")
                }
                SystemTile {
                    text: "Audio"
                    icon: "headphones"
                    detail: root.sinkReady ? (root.sink.nickname || root.sink.description || "") : ""
                    opensMenu: true
                    onClicked: Globals.toggleMenu("audio")
                }
                SystemTile {
                    text: "Keep awake"
                    icon: Globals.caffeinated ? "coffee" : "cup"
                    detail: Globals.caffeinated ? "On" : "Off"
                    active: Globals.caffeinated
                    onClicked: Globals.toggleCaffeine()
                }
            }
        }
    }
}
