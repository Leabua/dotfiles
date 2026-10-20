import Quickshell.Io
import QtQuick
import qs.templates

BarButton {
    id: root

    property int strength: 0
    property bool connected: false

    menu: "wifi"
    active: Globals.wifiMenuOpen

    property int sharedTick: Globals.tick
    onSharedTickChanged: wifiProc.running = true

    BarValue {
        id: value
        icon: root.connected ? "" : "wifiOff"

        // same fan + cut-offs as the network rows in the wifi menu. Open arcs carry less ink than the
        // closed icons beside them, so the bar draws them a touch heavier and lifts them off the bottom-heavy dot
        WifiSignal {
            visible: root.connected
            anchors.fill: parent
            anchors.topMargin: -1
            anchors.bottomMargin: 1
            strength: root.strength
            color: value.iconColor
            strokeWidth: Globals.barIconStroke + 0.2
            unlitOpacity: 0.35 // keeps the full fan visible at any signal, so the icon doesn't shrink with the level
        }
    }

    Process {
        id: wifiProc
        command: ["nmcli", "-t", "-f", "active,ssid,signal", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const active = text.trim().split("\n").find(line => line.startsWith("yes:"));
                root.connected = active !== undefined;
                root.strength = active ? parseInt(active.split(":").pop()) || 0 : 0;
            }
        }
        Component.onCompleted: running = true
    }
}
