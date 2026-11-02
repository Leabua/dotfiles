import Quickshell
import Quickshell.Io
import QtQuick
import qs.templates
import qs.bars
import qs.barModules
import qs.osd
// ------- menu modules: registered so the path-loaded menus can self-import their siblings -------
import qs.menus.wifi
import qs.menus.audio
import qs.menus.engineRoom
import qs.menus.launcher
import qs.menus.clipboard
import qs.menus.reminders
import qs.menus.preview
import qs.menus.system
import qs.menus.powerMenu

ShellRoot {
    id: root

    // ------- bar visibility -------
    property bool barVisible: true          // whole bar -> super + shift + space
    property bool rightIslandVisible: true  // wifi + system rail items -> super + alt + space (visible by default)

    // ------- mirror shown-state so menus slide to the edge when the rail hides -------
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

    // ------- one rail per output (bars/NiriBar.qml) -------
    Variants {
        id: rails
        model: Quickshell.screens
        NiriBar {}
    }

    Binding {
        target: Globals
        property: "barWindows"
        value: rails.instances
    }

    // ------- volume / brightness float over the top-right corner -------
    OsdOverlay {}

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
        source: "menus/preview/Preview.qml"
        active: true
    }
    LazyLoader {
        source: "menus/reminders/Reminders.qml"
        active: true
    }
    LazyLoader {
        source: "menus/system/SystemMenu.qml"
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
