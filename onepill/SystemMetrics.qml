import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: root

    property color fgColor: "#FFFFFF"
    property font textFont

    property int cpuPercent: 0
    property int memPercent: 0

    // State for CPU delta calculation
    property real lastCpuTotal: 0
    property real lastCpuIdle: 0

    spacing: 8

    // CPU Text
    Text {
        text: "󰍛 " + root.cpuPercent + "%"
        font: root.textFont
        color: {
            if (root.cpuPercent >= 80) return "#f38ba8";
            if (root.cpuPercent >= 70) return "#f9e2af";
            return root.fgColor;
        }
    }

    // Memory Text
    Text {
        text: "󰘚 " + root.memPercent + "%"
        font: root.textFont
        color: {
            if (root.memPercent >= 80) return "#f38ba8";
            if (root.memPercent >= 70) return "#f9e2af";
            return root.fgColor;
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: metricsProc.running = true
    }

    Process {
        id: metricsProc
        command: ["sh", "-c", "cat /proc/stat | grep '^cpu '; cat /proc/meminfo | grep -E '^MemTotal|^MemAvailable'"]

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split('\n');
                let mTotal = 0;
                let mAvail = 0;

                for (let line of lines) {
                    if (line.startsWith("cpu ")) {
                        // cpu  user nice system idle iowait irq softirq steal guest guest_nice
                        let parts = line.split(/\s+/);
                        let idle = parseFloat(parts[4]) + parseFloat(parts[5]); // idle + iowait
                        let total = 0;
                        for (let i = 1; i <= 7; i++) {
                            total += parseFloat(parts[i] || 0);
                        }

                        let diffIdle = idle - root.lastCpuIdle;
                        let diffTotal = total - root.lastCpuTotal;
                        
                        if (root.lastCpuTotal !== 0 && diffTotal > 0) {
                            root.cpuPercent = Math.round(100 * (diffTotal - diffIdle) / diffTotal);
                        }
                        
                        root.lastCpuIdle = idle;
                        root.lastCpuTotal = total;
                    } else if (line.startsWith("MemTotal:")) {
                        let parts = line.split(/\s+/);
                        mTotal = parseInt(parts[1]);
                    } else if (line.startsWith("MemAvailable:")) {
                        let parts = line.split(/\s+/);
                        mAvail = parseInt(parts[1]);
                    }
                }

                if (mTotal > 0 && mAvail > 0) {
                    root.memPercent = Math.round(100 * (mTotal - mAvail) / mTotal);
                }
            }
        }
    }
}
