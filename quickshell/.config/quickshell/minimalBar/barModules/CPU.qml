import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.templates

Item {
    id: root
    // instantiate the starting measurements
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    // define the height or nothing shows
    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    property int sharedTick: Globals.tick
    onSharedTickChanged: cpuFile.reload()

    property color displayColor: {
        if (cpuUsage > 85)
            return Globals.criticalColor;
        if (cpuUsage > 70)
            return Globals.warningColor;
        else
            return Globals.fgColor;
    }

    // read /proc/stat directly via FileView -> no subprocess spawned per tick
    FileView {
        id: cpuFile
        path: "/proc/stat"
        blockLoading: true
        onLoaded: {
            var p = text().split("\n")[0].trim().split(/\s+/); // aggregate "cpu ..." line
            var idle = parseInt(p[4]) + parseInt(p[5]);
            var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
            if (root.lastCpuTotal) {
                root.cpuUsage = Math.round(100 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal) * 100);
            }
            root.lastCpuIdle = idle;
            root.lastCpuTotal = total;
        }
        Component.onCompleted: reload()
    }

    BarIcon {
        id: content
        icon: "󰍛"
        displayText: root.cpuUsage + "%"
        color: root.displayColor

        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            // onClicked: Globals.engineRoomOpen = !Globals.engineRoomOpen
        }
    }
}
