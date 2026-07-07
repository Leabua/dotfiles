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
    onSharedTickChanged: memoryFile.reload()

    // read /proc/meminfo directly via FileView -> no subprocess spawned per tick
    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const t = text();
            const mt = t.match(/MemTotal:\s+(\d+)/);
            const ma = t.match(/MemAvailable:\s+(\d+)/);
            if (mt && ma)
                memoryItem.memoryUsage = Math.round((parseInt(mt[1]) - parseInt(ma[1])) / parseInt(mt[1]) * 100);
        }
        Component.onCompleted: reload()
    }

    RowLayout {
        id: row
        spacing: Globals.spacing - 1

        BarIcon {
            text: "󰘚"
        }
        Text {
            text: memoryItem.memoryUsage + "%"
            color: Globals.fgColor
            font: Globals.textFont
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.engineRoomOpen = !Globals.engineRoomOpen
    }
}
