import Quickshell.Io
import QtQuick
import qs.templates

Item {
    id: root

    property int strength: 0
    property bool connected: false

    property string icon: {
        if (!connected)
            return "󰤮";
        if (strength > 80)
            return "󰤨";
        if (strength > 60)
            return "󰤥";
        if (strength > 40)
            return "󰤢";
        return "󰤟";
    }

    property int sharedTick: Globals.tick
    onSharedTickChanged: wifiProc.running = true

    implicitHeight: bar.implicitHeight
    implicitWidth: bar.implicitWidth

    BarIcon {
        id: bar
        icon: root.icon
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor
        // onClicked: Globals.wifiMenuOpen = !Globals.wifiMenuOpen
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
                        root.strength = parseInt(parts[2]) || 0;
                        found = true;
                        break;
                    }
                }
                root.connected = found;
            }
        }
        Component.onCompleted: running = true
    }
}
