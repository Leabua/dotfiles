import Quickshell
import Quickshell.Io
import qs.menus.engineRoom
import qs.templates

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
        anchorCenterX: Globals.menuAnchorX

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
