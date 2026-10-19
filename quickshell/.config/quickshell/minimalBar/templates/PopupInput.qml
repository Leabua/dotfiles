pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import qs.templates

Scope {
    id: root
    property int popupSerial: 0

    function publishCard(): void {
        if (!Globals.popupClickThrough)
            return;
        const popup = Globals.activePopup;
        const rect = Globals.menuCardRect;
        const card = popup && popup.screen && rect.width > 0 ? "{" + [popup.screen.x + rect.x, popup.screen.y + rect.y, rect.width, rect.height, Globals.radius].join(",") + "}" : "nil";
        Hyprland.dispatch("function() local observer = _G.minimalBarPopupInput; if observer then observer.card = " + card + "; observer.serial = " + popupSerial + " end end");
    }

    // The compositor observes the original press without consuming it. Keep
    // dismissal here so the current card geometry remains the source of truth.
    IpcHandler {
        target: "popupInput"
        function outsideClick(x: int, y: int, serial: int): void {
            const popup = Globals.activePopup;
            if (!Globals.popupClickThrough || !popup || serial !== root.popupSerial)
                return;

            for (const bar of Globals.barWindows) {
                if (!bar.visible || !bar.screen)
                    continue;
                const bx = bar.screen.x + bar.margins.left;
                const by = bar.screen.y + bar.margins.top;
                if (x >= bx && x < bx + bar.width && y >= by && y < by + bar.height)
                    return; // bar buttons handle switching / dismissal themselves
            }

            if (!popup.containsGlobalPoint(x, y))
                popup.dismissed();
        }
    }

    Process {
        id: installObserver
        running: !!Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") && Hyprland.usingLua
        command: ["hyprctl", "eval", "local install = dofile(" + JSON.stringify(Quickshell.shellDir + "/templates/popup-input.lua") + "); install(" + JSON.stringify(Quickshell.shellDir) + ")"]
        onExited: exitCode => {
            Globals.popupClickThrough = exitCode === 0;
            if (Globals.popupClickThrough)
                Qt.callLater(root.publishCard);
            if (exitCode !== 0)
                console.warn("Popup click observer unavailable; using focus-grab dismissal");
        }
    }

    Connections {
        target: Globals
        function onActivePopupChanged(): void {
            root.popupSerial++;
            Qt.callLater(root.publishCard);
        }
        function onMenuCardRectChanged(): void { Qt.callLater(root.publishCard); }
        function onFocusedScreenChanged(): void { Qt.callLater(root.publishCard); }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event): void {
            // Hyprland recreates its Lua state and bindings when it reloads.
            if (event.name === "configreloaded" && Hyprland.usingLua) {
                Globals.popupClickThrough = false;
                installObserver.running = true;
            }
        }
    }
}
