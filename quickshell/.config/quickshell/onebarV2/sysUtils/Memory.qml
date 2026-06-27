import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.defaults

Item {
    id: memoryItem
    // initial memory usage is 0, updated by memoryProcess on read
    property int memoryUsage: 0

    // dynamic height/width based on text size
    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    // using global tick from Globals.tick
    property int sharedTick: Globals.tick
    onSharedTickChanged: memoryProcess.running = true

    Process {
        id: memoryProcess
        command: ["cat", "/proc/meminfo"]
        // used% from /proc/meminfo (MemTotal - MemAvailable) -> one read, no shell + pipe
        stdout: StdioCollector {
            onStreamFinished: {
                const mt = text.match(/MemTotal:\s+(\d+)/);
                const ma = text.match(/MemAvailable:\s+(\d+)/);
                if (mt && ma)
                    memoryItem.memoryUsage = Math.round((parseInt(mt[1]) - parseInt(ma[1])) / parseInt(mt[1]) * 100);
            }
        }
        Component.onCompleted: running = true // avoids having to wait for the timer to fire just to get the memory to start going
    }

    RowLayout {
        id: row
        spacing: Globals.spacing - 1// in-pair gap: icon hugs its value

        BarIcon {
            text: "󰘚"
        }
        Text {
            text: memoryItem.memoryUsage + "%"
            color: Globals.fgColor
            font: Globals.textFont
        }
    }
}
