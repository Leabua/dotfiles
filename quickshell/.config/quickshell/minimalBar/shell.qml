import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.templates
import qs.barModules
import qs.osd
// ------- menu modules: registered so the path-loaded menus can self-import their siblings -------
import qs.menus.wifi
import qs.menus.audio
import qs.menus.engineRoom
import qs.menus.launcher
import qs.menus.clipboard
import qs.menus.reminders

ShellRoot {
    id: root

    // ------- bar visibility -------
    property bool barVisible: true          // whole bar -> super + shift + space
    property bool rightIslandVisible: true  // right cluster only -> super + alt + space (visible by default)

    PopupInput {}

    Variants {
        id: bars
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            property var modelData
            screen: modelData
            color: "transparent"
            WlrLayershell.namespace: "minimalbar-bar"

            visible: root.barVisible

            // make go top
            anchors {
                top: true
                left: true
                right: true
            }

            // give some padding
            margins {
                top: Globals.marginsTop
                left: Globals.marginsLeft
                right: Globals.marginsRight
                bottom: Globals.marginsBottom
            }
            implicitHeight: Globals.barIslandHeight // fixed -> the bar never jitters with its content

            // Empty space on the bar also dismisses the current menu. Buttons
            // above this area keep handling their own clicks normally.
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onClicked: Globals.dismissPopup()
            }

            // ------- mirror shown-state so menus slide up when the bar hides -------
            Binding {
                target: Globals
                property: "barShown"
                value: root.barVisible
            }
            Binding {
                target: Globals
                property: "rightIslandShown"
                value: root.rightIslandVisible
            }

            // ------- left: OSDs + now playing; only one shows at a time, and the island vanishes when none do -------
            BarIsland {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                padding: Globals.barIslandSidePadding + Globals.barItemPadding

                VolumeOSD {}
                BrightnessOSD {}
                MediaScriptOSD {}
            }

            // ------- centre: power menu, clock, workspaces, alerts mirrored while the right island is hidden -------
            BarIsland {
                anchors.centerIn: parent
                padding: Globals.barIslandInset // tighter ends than the side islands

                Logo {}
                Clock {}
                Workspaces {}
                CriticalAlerts {}
            }

            // ------- right: status, one pill per menu -------
            BarIsland {
                visible: root.rightIslandVisible
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                SystemLoad {}
                Volume {}
                Battery {}
                Wifi {}
                Caffeine {}
            }
        }
    }

    Binding {
        target: Globals
        property: "barWindows"
        value: bars.instances
    }

    // ------- single-instance low-battery notifier (fires once, not per-screen) -------
    BatteryWarnings {}

    // ------- menus: mounted once, opened via bar clicks / ipc -------
    LazyLoader {
        source: "menus/audio/AudioMenu.qml"
        active: true
    }
    LazyLoader {
        source: "menus/clipboard/Clipboard.qml"
        active: true
    }
    LazyLoader {
        source: "menus/engineRoom/EngineRoom.qml"
        active: true
    }
    LazyLoader {
        source: "menus/launcher/Launcher.qml"
        active: true
    }
    LazyLoader {
        source: "menus/notifications/Notifications.qml"
        active: true
    }
    LazyLoader {
        source: "menus/powerProfiles/PowerProfiles.qml"
        active: true
    }
    LazyLoader {
        source: "menus/powerMenu/PowerMenu.qml"
        active: true
    }
    LazyLoader {
        source: "menus/reminders/Reminders.qml"
        active: true
    }
    LazyLoader {
        source: "menus/wifi/WifiMenu.qml"
        active: true
    }

    // ------- hide the whole bar -> super + shift + space -------
    IpcHandler {
        target: "bar"
        function toggle(): void {
            root.barVisible = !root.barVisible;
        }
        function show(): void {
            root.barVisible = true;
        }
        function hide(): void {
            root.barVisible = false;
        }
    }

    // ------- toggle just the right island -> super + alt + space -------
    IpcHandler {
        target: "rightIsland"
        function toggle(): void {
            root.rightIslandVisible = !root.rightIslandVisible;
        }
        function show(): void {
            root.rightIslandVisible = true;
        }
        function hide(): void {
            root.rightIslandVisible = false;
        }
    }
}
