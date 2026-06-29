import Quickshell
import Quickshell.Io
import qs.audio
import qs.defaults

import QtQuick

Scope {
    id: root

    IpcHandler {
        target: "audioMenu"
        function toggle(): void {
            Globals.audioMenuOpen = !Globals.audioMenuOpen;
        }
        function show(): void {
            Globals.audioMenuOpen = true;
        }
        function hide(): void {
            Globals.audioMenuOpen = false;
        }
    }

    // always reopen on the audio card, never wherever it was last left
    Connections {
        target: Globals
        function onAudioMenuOpenChanged(): void {
            if (Globals.audioMenuOpen)
                Globals.audioMenuView = "audio";
        }
    }

    PopupWindow {
        open: Globals.audioMenuOpen
        onDismissed: Globals.audioMenuOpen = false
        hAlign: "center"
        // sit just below the bar when it's shown, shift up to the top when it's hidden
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: Globals.spacing

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0) // below the bar when shown, screen top when hidden
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        // only the active card is instantiated, so it owns its own service bindings and the card resizes cleanly between the two

        Loader {
            sourceComponent: Globals.audioMenuView === "bluetooth" ? bluetoothComponent : audioComponent
        }

        Component {
            id: audioComponent
            AudioView {}
        }

        Component {
            id: bluetoothComponent
            BluetoothView {}
        }
    }
}
