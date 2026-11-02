pragma ComponentBehavior: Bound

import Quickshell.Io
import qs.menus.engineRoom
import qs.templates
import "GpuMath.js" as GpuMath

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property int availableWidth: 680
    // embedders (niri's system menu) sample while their own card is open and draw their own header
    property bool live: Globals.engineRoomOpen
    property bool showHeader: true
    readonly property int cardWidth: Math.min(680, availableWidth)

    width: root.cardWidth
    spacing: 8

    // ---------- colour helpers ----------
    function lerpColor(a: color, b: color, t: real): color {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    // calm -> amber -> error ramp for load-style values (0 = cool, 1 = hot). Stays primary until the rail's own
    // warning threshold, so ordinary load reads as the theme colour rather than an early warning
    function heatColor(f: real): color {
        f = Math.max(0, Math.min(1, f));
        const warn = Globals.loadWarning / 100;
        const crit = Globals.loadCritical / 100;
        if (f <= warn)
            return Globals.primary;
        if (f <= crit)
            return root.lerpColor(Globals.primary, Globals.warningColor, (f - warn) / (crit - warn));
        return root.lerpColor(Globals.warningColor, Globals.criticalColor, (f - crit) / (1 - crit));
    }

    // ---------- CPU ----------
    property real cpuOverall: 0        // 0..1
    property var coreUsages: []        // [0..1] per core
    property int cpuTemp: 0            // deg C
    property string loadAvg: "—"

    // per-key jiffy baselines so we can diff between samples ("all" + each core)
    property var _lastIdle: ({})
    property var _lastTotal: ({})

    function parseCpu(text: string): void {
        const cores = [];
        let overall = root.cpuOverall;
        for (const line of text.split("\n")) {
            const m = line.match(/^cpu(\d*)\s+(\d.*)$/);
            if (!m)
                continue;
            const nums = m[2].trim().split(/\s+/).map(x => parseInt(x));
            const idle = nums[3] + (nums.length > 4 ? nums[4] : 0); // idle + iowait
            const total = nums.slice(0, 8).reduce((a, b) => a + (b || 0), 0);
            const key = m[1] === "" ? "all" : ("c" + m[1]);
            const li = root._lastIdle[key];
            const lt = root._lastTotal[key];
            let frac = 0;
            if (lt !== undefined && total > lt)
                frac = Math.max(0, Math.min(1, 1 - (idle - li) / (total - lt)));
            root._lastIdle[key] = idle;
            root._lastTotal[key] = total;
            if (key === "all")
                overall = frac;
            else
                cores.push(frac);
        }
        root.cpuOverall = overall;
        root.coreUsages = cores;
    }

    // ---------- Memory ----------
    property real memUsedFrac: 0
    property string memUsedStr: "-"
    property string cacheStr: "-"
    property real swapFrac: 0
    property string swapStr: "-"

    function fmtGiB(kib: real): string {
        const gib = kib / 1048576;
        return (gib >= 10 ? gib.toFixed(0) : gib.toFixed(1)) + " GiB";
    }
    function parseMem(text: string): void {
        const field = k => {
            const m = text.match(new RegExp("^" + k + ":\\s+(\\d+)", "m"));
            return m ? parseInt(m[1]) : 0;
        };
        const total = field("MemTotal");
        const avail = field("MemAvailable");
        const swapTotal = field("SwapTotal");
        const swapFree = field("SwapFree");
        const cached = field("Cached");
        const used = total - avail;
        root.memUsedFrac = total > 0 ? used / total : 0;
        root.memUsedStr = root.fmtGiB(used) + " / " + root.fmtGiB(total);
        root.cacheStr = root.fmtGiB(cached);
        root.swapFrac = swapTotal > 0 ? (swapTotal - swapFree) / swapTotal : 0;
        root.swapStr = swapTotal > 0 ? root.fmtGiB(swapTotal - swapFree) + " / " + root.fmtGiB(swapTotal) : "off";
    }

    // ---------- Intel GPU ----------
    // Global engine counters require perf privileges on this host. RC6 instead
    // gives awake time, which is labelled explicitly and is independent of MHz.
    property real gpuAwake: -1  // 0..1, or unavailable
    property int gpuCurFreq: -1 // actual MHz, not the driver's requested clock
    property int gpuMaxFreq: -1 // configured clock limit in MHz
    property var _lastGpuSample: null

    function parseGpu(text: string): void {
        if (!root.live)
            return;
        const sample = GpuMath.parseSample(text);
        root.gpuAwake = GpuMath.awakeFraction(root._lastGpuSample, sample);
        root.gpuCurFreq = sample ? sample.clock : -1;
        root.gpuMaxFreq = sample ? sample.maximum : -1;
        root._lastGpuSample = sample;
    }

    // ---------- sampling (only while open) ----------
    function refresh(): void {
        BatteryStats.recordBatteryEnergy();
        cpuFile.reload();
        memFile.reload();
        loadFile.reload();
        tempProc.running = true; // sysfs globs -> stay as Process
        gpuProc.running = true;
    }

    Timer {
        interval: 1500
        repeat: true
        running: root.live
        triggeredOnStart: true // sample immediately on open (CPU needs a second tick to diff)
        onTriggered: root.refresh()
        onRunningChanged: {
            root._lastGpuSample = null;
            root.gpuAwake = -1;
        }
    }

    // /proc reads via FileView -> no per-tick subprocess (temp/gpu below still glob sysfs)
    FileView {
        id: cpuFile
        path: "/proc/stat"
        blockLoading: true
        onLoaded: root.parseCpu(text())
    }
    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: root.parseMem(text())
    }
    Process {
        id: tempProc
        // prefer the CPU package sensor, fall back to zone0
        command: ["sh", "-c", "for z in /sys/class/thermal/thermal_zone*; do [ \"$(cat $z/type)\" = x86_pkg_temp ] && cat $z/temp && exit; done; cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuTemp = Math.round(parseInt(text) / 1000) || 0
        }
    }
    FileView {
        id: loadFile
        path: "/proc/loadavg"
        blockLoading: true
        onLoaded: root.loadAvg = text().trim().split(/\s+/).slice(0, 3).join("  ")
    }
    Process {
        id: gpuProc
        command: ["sh", decodeURIComponent(Qt.resolvedUrl("GpuSample.sh").toString().replace(/^file:\/\//, ""))]
        stdout: StdioCollector {
            onStreamFinished: root.parseGpu(text)
        }
    }

    MenuHeader {
        visible: root.showHeader
        title: "Engine Room"
        icon: "activity"
        onCloseRequested: Globals.engineRoomOpen = false
    }

    GridLayout {
        Layout.fillWidth: true
        columns: root.cardWidth >= 560 ? 3 : 1
        columnSpacing: 8
        rowSpacing: 8

        Tile {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true

            EngineMeter {
                Layout.fillWidth: true
                label: "Processor"
                icon: "cpu"
                value: root.cpuOverall
                accent: root.heatColor(root.cpuOverall)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                StatLine {
                    key: "Temperature"
                    val: root.cpuTemp > 0 ? root.cpuTemp + "°C" : "—"
                    valColor: root.cpuTemp >= 80 ? root.heatColor((root.cpuTemp - 40) / 50) : Globals.surfaceContent
                }
                StatLine {
                    key: "Load average"
                    val: root.loadAvg
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 3

                Repeater {
                    model: root.coreUsages
                    delegate: Rectangle {
                        id: coreBar
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        Layout.preferredHeight: 24
                        radius: 4
                        color: Globals.surfaceContainerHighest

                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: Math.max(1, parent.height * Math.max(0, Math.min(1, coreBar.modelData)))
                            radius: parent.radius
                            color: root.heatColor(coreBar.modelData)
                        }
                    }
                }
            }
        }

        Tile {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true

            EngineMeter {
                Layout.fillWidth: true
                label: "Graphics"
                detail: "Awake time"
                icon: "gpu"
                value: root.gpuAwake
                available: root.gpuAwake >= 0
                accent: root.heatColor(root.gpuAwake)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                StatLine {
                    key: "Actual clock"
                    val: root.gpuCurFreq >= 0 ? root.gpuCurFreq + " MHz" : "—"
                }
                StatLine {
                    key: "Maximum"
                    val: root.gpuMaxFreq > 0 ? root.gpuMaxFreq + " MHz" : "—"
                }
            }
        }

        Tile {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true

            EngineMeter {
                Layout.fillWidth: true
                label: "Memory"
                icon: "memory"
                value: root.memUsedFrac
                accent: root.heatColor(root.memUsedFrac)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                StatLine {
                    key: "Used"
                    val: root.memUsedStr
                }
                StatLine {
                    key: "Cache"
                    val: root.cacheStr
                }
                StatLine {
                    key: "Swap"
                    val: root.swapStr
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 2
                color: Globals.surfaceContainerHighest

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.swapFrac))
                    height: parent.height
                    radius: parent.radius
                    color: root.heatColor(root.swapFrac)
                }
            }
        }
    }

    BatteryCard {
        columns: root.cardWidth >= 560 ? 4 : 2
    }
}
