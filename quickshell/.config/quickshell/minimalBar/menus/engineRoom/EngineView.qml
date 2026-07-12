pragma ComponentBehavior: Bound

import Quickshell.Io
import Quickshell.Services.UPower
import qs.menus.engineRoom
import qs.templates

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    // fixed card body width -> four even gauge columns
    readonly property int cardWidth: 684
    readonly property int gaugeSize: 104

    spacing: Globals.spacing

    // ---------- colour helpers ----------
    function lerpColor(a: color, b: color, t: real): color {
        return Qt.rgba(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, 1);
    }

    // green -> amber -> red ramp for load-style values (0 = cool, 1 = hot)
    function heatColor(f: real): color {
        f = Math.max(0, Math.min(1, f));
        return f < 0.5 ? root.lerpColor(Globals.healthy, Globals.warningColor, f / 0.5) : root.lerpColor(Globals.warningColor, Globals.criticalColor, (f - 0.5) / 0.5);
    }

    // ---------- CPU ----------
    property real cpuOverall: 0        // 0..1
    property var coreUsages: []        // [0..1] per core
    property int cpuTemp: 0            // deg C
    property string loadAvg: "—"

    // per-key jiffy baselines so we can diff between samples ("all" + each core)
    property var _lastIdle: ({})
    property var _lastTotal: ({})

    // pure vibecoding
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
        return (gib >= 10 ? gib.toFixed(0) : gib.toFixed(1)) + "G";
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
        root.memUsedStr = root.fmtGiB(used) + " / " + root.fmtGiB(total) + " (" + Math.round(root.memUsedFrac * 100) + "%)";
        root.cacheStr = root.fmtGiB(cached);
        root.swapFrac = swapTotal > 0 ? (swapTotal - swapFree) / swapTotal : 0;
        root.swapStr = swapTotal > 0 ? root.fmtGiB(swapTotal - swapFree) + " / " + root.fmtGiB(swapTotal) : "off";
    }

    // ---------- GPU (Intel iGPU: no root, no nvidia-smi) ----------
    // not sure how if this would work for a dedicate gpu
    // busy% from RC6 idle-residency delta; clock from the i915 sysfs freq knobs.
    // (an Intel iGPU has no dedicated temp/VRAM sensor -- it shares the CPU package.)
    property real gpuBusy: 0     // 0..1
    property int gpuCurFreq: 0   // MHz
    property int gpuMaxFreq: 0   // MHz
    property real _lastRc6: -1   // RC6 (idle) residency ms at last sample
    property real _lastWall: -1  // /proc/uptime ms at last sample

    function parseGpu(text: string): void {
        const l = text.trim().split("\n");
        const rc6 = parseFloat(l[0]);         // idle-residency ms
        const cur = parseInt(l[1]);
        const max = parseInt(l[2]);
        const wall = parseFloat(l[3]) * 1000; // /proc/uptime seconds -> ms
        if (!isNaN(cur))
            root.gpuCurFreq = cur;
        if (!isNaN(max))
            root.gpuMaxFreq = max;
        if (!isNaN(rc6) && !isNaN(wall) && root._lastWall >= 0) {
            const dW = wall - root._lastWall;
            const dR = rc6 - root._lastRc6;
            if (dW > 0) // active fraction = wall time not spent idling in RC6
                root.gpuBusy = Math.max(0, Math.min(1, 1 - dR / dW));
        }
        if (!isNaN(rc6))
            root._lastRc6 = rc6;
        if (!isNaN(wall))
            root._lastWall = wall;
    }

    // ---------- Battery ----------
    readonly property var bat: UPower.displayDevice
    readonly property bool batReady: bat && bat.ready
    readonly property bool charging: root.batReady && bat.state === UPowerDeviceState.Charging
    readonly property bool full: root.batReady && bat.state === UPowerDeviceState.FullyCharged
    readonly property int batPercent: root.batReady ? Math.round(bat.percentage * 100) : 0
    readonly property real batFrac: root.batReady ? bat.percentage : 0

    readonly property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property var defaultIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    function batGlyph(): string {
        if (!root.batReady)
            return "󰂃";
        if (root.full || (root.charging && root.batPercent === 100))
            return "󰂅";
        const idx = Math.min(Math.floor(root.batPercent / 10), 9);
        return (root.charging ? root.chargingIcons[idx] : root.defaultIcons[idx]).trim();
    }
    // mirror BatteryIcons.displayColor exactly so the gauge matches the bar icon
    function batColor(): color {
        if (!root.batReady)
            return Globals.fgColor;
        if (root.batPercent <= 10 && !root.charging)
            return Globals.criticalColor;
        if (root.batPercent <= 20 && !root.charging)
            return Globals.warningColor;
        if (root.batPercent >= 80 && root.charging)
            return Globals.healthy;
        return Globals.fgColor;
    }
    function fmtTime(sec: real): string {
        if (!sec || sec <= 0)
            return "—";
        const h = Math.floor(sec / 3600);
        const m = Math.floor((sec % 3600) / 60);
        return h > 0 ? (h + "h " + m + "m") : (m + "m");
    }
    function rateStr(): string {
        if (!root.batReady)
            return "—";
        const w = bat.changeRate;
        if (!w || w <= 0.05)
            return "—";
        return (root.charging ? "+" : "-") + w.toFixed(1) + " W";
    }
    function timeStr(): string {
        if (!root.batReady)
            return "—";
        return root.charging ? root.fmtTime(bat.timeToFull) : root.fmtTime(bat.timeToEmpty);
    }
    function healthStr(): string {
        if (!root.batReady || !bat.healthPercentage)
            return "—";
        const raw = bat.healthPercentage;
        return Math.round(raw <= 1.5 ? raw * 100 : raw) + "%"; // normalise 0..1 or 0..100
    }
    function stateStr(): string {
        if (!root.batReady)
            return "—";
        switch (bat.state) {
        case UPowerDeviceState.Charging:
            return "Charging";
        case UPowerDeviceState.Discharging:
            return "Discharging";
        case UPowerDeviceState.FullyCharged:
            return "Full";
        case UPowerDeviceState.PendingCharge:
        case UPowerDeviceState.PendingDischarge:
            return "Pending";
        default:
            return "—";
        }
    }

    // ---------- sampling (only while open) ----------
    function refresh(): void {
        cpuFile.reload();
        memFile.reload();
        loadFile.reload();
        tempProc.running = true; // sysfs globs -> stay as Process
        gpuProc.running = true;
    }

    Timer {
        interval: 1500
        repeat: true
        running: Globals.engineRoomOpen
        triggeredOnStart: true // sample immediately on open (CPU needs a second tick to diff)
        onTriggered: root.refresh()
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
        // rc6 idle-residency, current + max clock, then uptime -- one shot, one parse.
        // card* glob grabs whichever DRM node is the i915 (single-GPU laptop).
        command: ["sh", "-c", "cat /sys/class/drm/card*/power/rc6_residency_ms 2>/dev/null | head -1; cat /sys/class/drm/card*/gt_cur_freq_mhz 2>/dev/null | head -1; cat /sys/class/drm/card*/gt_max_freq_mhz 2>/dev/null | head -1; cat /proc/uptime"]
        stdout: StdioCollector {
            onStreamFinished: root.parseGpu(text)
        }
    }

    // strut: pins the card body width so the three columns divide evenly
    Item {
        Layout.preferredWidth: root.cardWidth
        Layout.preferredHeight: 0
    }

    // ---------- header ----------
    RowLayout {
        Layout.fillWidth: true
        Text {
            text: "󰇺" // nf-md-engine (f01fa)
            visible: Globals.headerIcons
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 6
            font.weight: Globals.textFont.weight
        }
        Text {
            Layout.fillWidth: true
            text: "Engine Room"
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 2
            font.weight: Globals.textFont.weight
        }
    }

    MenuDivider {}

    // ---------- the three columns ----------
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Globals.spacing
        spacing: Globals.spacing + 6 // clear the CPU values off the next column's labels

        // ===== CPU =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: Globals.spacing

            RadialGauge {
                Layout.alignment: Qt.AlignHCenter
                diameter: root.gaugeSize
                glyph: String.fromCodePoint(0xF2DB)
                value: root.cpuOverall
                caption: Math.round(root.cpuOverall * 100) + "%"
                arcColor: root.heatColor(root.cpuOverall)
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "CPU"
                color: Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 3
                font.letterSpacing: 2
                font.weight: Globals.textFont.weight
            }

            // per-core equaliser
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                spacing: 3
                Repeater {
                    model: root.coreUsages
                    delegate: Rectangle {
                        id: coreBar
                        required property var modelData
                        width: 7
                        height: 30
                        radius: 3
                        color: Qt.alpha(Globals.fgColor, 0.15)
                        Rectangle {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: parent.height * Math.max(0, Math.min(1, coreBar.modelData))
                            radius: parent.radius
                            color: root.heatColor(coreBar.modelData)
                            Behavior on height {
                                NumberAnimation {
                                    duration: Globals.animDuration
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }
                }
            }

            StatLine {
                key: "Temp"
                val: root.cpuTemp > 0 ? root.cpuTemp + "°C" : "—"
                valColor: root.heatColor((root.cpuTemp - 40) / 50) // ~40°C cool .. ~90°C hot
            }
            StatLine {
                key: "Load"
                val: root.loadAvg
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Qt.alpha(Globals.fgColor, 0.12)
        }

        // ===== GPU =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: Globals.spacing

            RadialGauge {
                Layout.alignment: Qt.AlignHCenter
                diameter: root.gaugeSize
                glyph: "󰢮" // nf-md-expansion-card (graphics card)
                value: root.gpuBusy
                caption: Math.round(root.gpuBusy * 100) + "%"
                arcColor: root.heatColor(root.gpuBusy)
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "GPU"
                color: Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 3
                font.letterSpacing: 2
                font.weight: Globals.textFont.weight
            }

            StatLine {
                key: "Clock"
                val: root.gpuCurFreq > 0 ? root.gpuCurFreq + " MHz" : "—"
            }
            StatLine {
                key: "Max"
                val: root.gpuMaxFreq > 0 ? root.gpuMaxFreq + " MHz" : "—"
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Qt.alpha(Globals.fgColor, 0.12)
        }

        // ===== Memory =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: Globals.spacing

            RadialGauge {
                Layout.alignment: Qt.AlignHCenter
                diameter: root.gaugeSize
                glyph: "󰘚"
                value: root.memUsedFrac
                caption: Math.round(root.memUsedFrac * 100) + "%"
                arcColor: root.heatColor(root.memUsedFrac)
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "MEM"
                color: Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 3
                font.letterSpacing: 2
                font.weight: Globals.textFont.weight
            }

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
            // swap meter
            Rectangle {
                Layout.fillWidth: true
                height: 5
                radius: 3
                color: Qt.alpha(Globals.fgColor, 0.15)
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * Math.max(0, Math.min(1, root.swapFrac))
                    radius: parent.radius
                    color: root.heatColor(root.swapFrac)
                    Behavior on width {
                        NumberAnimation {
                            duration: Globals.animDuration
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Qt.alpha(Globals.fgColor, 0.12)
        }

        // ===== Battery =====
        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: Globals.spacing

            RadialGauge {
                Layout.alignment: Qt.AlignHCenter
                diameter: root.gaugeSize
                glyph: root.batGlyph()
                value: root.batFrac
                caption: root.batPercent + "%"
                arcColor: root.batColor()
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "BAT"
                color: Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 3
                font.letterSpacing: 2
                font.weight: Globals.textFont.weight
            }

            StatLine {
                key: root.charging ? "Charge" : "Drain"
                val: root.rateStr()
                valColor: root.charging ? Globals.healthy : Globals.fgColor
            }
            StatLine {
                key: root.charging ? "Full in" : "Left"
                val: root.timeStr()
            }
            StatLine {
                key: "Health"
                val: root.healthStr()
            }
            StatLine {
                key: "State"
                val: root.stateStr()
            }
        }
    }
}
