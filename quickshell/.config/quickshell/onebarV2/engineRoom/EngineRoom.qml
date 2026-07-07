import Quickshell
import Quickshell.Io
import qs.engineRoom
import qs.defaults

import QtQuick

// Host for the "Engine Room" system-monitor card. Opened from the CPU or Memory
// bar rows (they toggle Globals.engineRoomOpen), or via the "engineRoom" IPC.
Scope {
    id: root

    IpcHandler {
        target: "engineRoom"
        function toggle(): void {
            Globals.engineRoomOpen = !Globals.engineRoomOpen;
        }
        function show(): void {
            Globals.engineRoomOpen = true;
        }
        function hide(): void {
            Globals.engineRoomOpen = false;
        }
    }

    PopupWindow {
        open: Globals.engineRoomOpen
        onDismissed: Globals.engineRoomOpen = false
        hAlign: "center"
        // sit just below the bar when it's shown, shift to the screen top when hidden
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: Globals.spacing

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        Loader {
            sourceComponent: engineComponent
        }

        Component {
            id: engineComponent
            EngineView {}
        }
    }
}
