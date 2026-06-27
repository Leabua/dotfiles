import Quickshell.Io
import QtQuick
import qs.defaults

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

    implicitHeight: textID.height
    implicitWidth: textID.implicitWidth
    BarIcon {
        id: textID
        text: root.icon
        font.pixelSize: Globals.barIconSize + 2

        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: Globals.wifiMenuOpen = !Globals.wifiMenuOpen
        }
    }
}
