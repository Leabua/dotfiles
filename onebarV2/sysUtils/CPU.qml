pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Io //for process type -> shoutout Tony on yt
import qs

Item {
    id: root
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth

    property int sharedTick: Globals.tick
    onSharedTickChanged: cpuProc.running = true

    property color displayColor: {
        if (cpuUsage > 85)
            return Globals.criticalColor;
        if (cpuUsage > 70)
            return Globals.warningColor;
        else
            return Globals.fgColor;
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (root.lastCpuTotal) {
                    root.cpuUsage = Math.round(100 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal) * 100);
                }
                root.lastCpuIdle = idle;
                root.lastCpuTotal = total;
            }
        }
        Component.onCompleted: running = true
    }

    Text {
        id: textID
        text: "󰍛 " + root.cpuUsage + "%"
        font: Globals.textFont
        color: root.displayColor
    }
}
