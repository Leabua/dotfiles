import QtQuick
import Quickshell.Io
import qs.templates

// cpu + ram share one pill because they open the same menu (engine room)
BarButton {
    id: root

    property int cpuUsage: 0
    property int memUsage: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0

    menu: "engineRoom"
    active: Globals.engineRoomOpen

    property int sharedTick: Globals.tick
    onSharedTickChanged: {
        cpuFile.reload();
        memFile.reload();
    }

    BarValue {
        icon: "cpu"
        text: root.cpuUsage + "%"
        tint: Globals.loadTint(root.cpuUsage)
    }
    BarValue {
        icon: "memory"
        text: root.memUsage + "%"
        tint: Globals.loadTint(root.memUsage)
    }

    // the centre island mirrors these while the right island is hidden
    Binding {
        target: Globals
        property: "cpuUsage"
        value: root.cpuUsage
    }
    Binding {
        target: Globals
        property: "memUsage"
        value: root.memUsage
    }

    // read /proc directly via FileView -> no subprocess spawned per tick
    FileView {
        id: cpuFile
        path: "/proc/stat"
        blockLoading: true
        onLoaded: {
            const p = text().split("\n")[0].trim().split(/\s+/); // aggregate "cpu ..." line
            const idle = parseInt(p[4]) + parseInt(p[5]);
            const total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
            if (root.lastCpuTotal)
                root.cpuUsage = Math.round(100 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal) * 100);
            root.lastCpuIdle = idle;
            root.lastCpuTotal = total;
        }
        Component.onCompleted: reload()
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const t = text();
            const total = t.match(/MemTotal:\s+(\d+)/);
            const available = t.match(/MemAvailable:\s+(\d+)/);
            if (total && available)
                root.memUsage = Math.round((parseInt(total[1]) - parseInt(available[1])) / parseInt(total[1]) * 100);
        }
        Component.onCompleted: reload()
    }
}
