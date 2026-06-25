pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

StatusButton {
    id: wifiBtn

    property int strength: 0
    property bool connected: false

    isActive: connected
    invertWhenOff: true

    icon: {
        if (!connected) return "󰤮";
        if (strength > 80) return "󰤨";
        if (strength > 60) return "󰤥";
        if (strength > 40) return "󰤢";
        return "󰤟";
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: wifiProc.running = true
    }

    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "active,ssid,signal", "dev", "wifi"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split('\n');
                let found = false;
                for (let line of lines) {
                    if (line.startsWith("yes:")) {
                        let parts = line.split(':');
                        wifiBtn.strength = parseInt(parts[2]) || 0;
                        found = true;
                        break;
                    }
                }
                wifiBtn.connected = found;
            }
        }
    }
}
