import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.templates

Item {
    id: root
    property int memoryUsage: 0

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    property int sharedTick: Globals.tick
    onSharedTickChanged: memoryFile.reload()

    FileView {
        id: memoryFile
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const t = text();
            const mt = t.match(/MemTotal:\s+(\d+)/);
            const ma = t.match(/MemAvailable:\s+(\d+)/);
            if (mt && ma)
                root.memoryUsage = Math.round((parseInt(mt[1]) - parseInt(ma[1])) / parseInt(mt[1]) * 100);
        }
        Component.onCompleted: reload()
    }

    BarIcon {
        id: row
        icon: "󰘚 "
        displaytext: root.memoryUsage + "%"
        color: root.memoryUsage > 85 ? Globals.criticalColor : root.memoryUsage > 70 ? Globals.warningColor : Globals.fgColor
        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: Globals.engineRoomOpen = !Globals.engineRoomOpen
        }
    }
}
