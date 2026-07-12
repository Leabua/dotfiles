import Quickshell
import Quickshell.Io
import qs.menus.wifi
import qs.templates

import QtQuick

Scope {
    id: root

    IpcHandler {
        target: "wifiMenu"
        function toggle(): void {
            Globals.wifiMenuOpen = !Globals.wifiMenuOpen;
        }
        function show(): void {
            Globals.wifiMenuOpen = true;
        }
        function hide(): void {
            Globals.wifiMenuOpen = false;
        }
    }

    PopupWindow {
        open: Globals.wifiMenuOpen
        onDismissed: Globals.wifiMenuOpen = false
        hAlign: "center"
        anchorCenterX: Globals.menuAnchorX // open under the bar button that toggled it
        // sit just below the bar when it's shown, shift up to the top when it's hidden
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: Globals.spacing
        onKeyDown: event => wifiView.handleKey(event)

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0) // below the bar when shown, screen top when hidden
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        WifiView {
            id: wifiView
        }
    }
}
