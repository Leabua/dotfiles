import QtQuick
import Quickshell.Io
import qs.defaults

Item {
    id: memoryItem
    // initial memory usage is 0, updated by memoryProcess on read
    property int memoryUsage: 0

    // dynamic height/width based on text size
    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth

    // using global tick from Globals.tick
    property int sharedTick: Globals.tick
    onSharedTickChanged: memoryProcess.running = true

    property color displayColor: {
        if (memoryUsage > 85)
            return Globals.criticalColor;
        if (memoryUsage > 70)
            return Globals.warningColor;
        else
            return Globals.fgColor;
    }
    Process {
        id: memoryProcess
        command: ["sh", "-c", "free | grep Mem"]
        // read memory usage from free command output
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                memoryItem.memoryUsage = Math.round((used / total) * 100);
            }
        }
        Component.onCompleted: running = true // avoids having to wait for the timer to fire just to get the memory to start going
    }

    // what I see
    Text {
        id: textID
        text: "󰘚" + " " + memoryItem.memoryUsage + "%"
        font: Globals.textFont
        color: Globals.fgColor
    }
}
