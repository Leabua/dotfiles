pragma ComponentBehavior: Bound

import Quickshell.Io
import Quickshell.Services.UPower
import qs.menus.engineRoom
import qs.templates
import "BatteryMath.js" as BatteryMath
import "GpuMath.js" as GpuMath

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property int availableWidth: 680
    readonly property int cardWidth: Math.min(680, availableWidth)

    width: root.cardWidth
    spacing: 20

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
        if (!Globals.engineRoomOpen)
            return;
        const sample = GpuMath.parseSample(text);
        root.gpuAwake = GpuMath.awakeFraction(root._lastGpuSample, sample);
        root.gpuCurFreq = sample ? sample.clock : -1;
        root.gpuMaxFreq = sample ? sample.maximum : -1;
        root._lastGpuSample = sample;
    }

    // ---------- Battery ----------
    // The aggregate display device omits health; use the actual laptop battery.
    readonly property var bat: BatteryMath.pickBattery(UPower.devices.values, UPower.displayDevice)
    readonly property bool batReady: bat && bat.ready
    readonly property bool charging: root.batReady && bat.state === UPowerDeviceState.Charging
    readonly property bool full: root.batReady && bat.state === UPowerDeviceState.FullyCharged
    readonly property int batPercent: root.batReady ? Math.round(bat.percentage * 100) : 0
    readonly property real batFrac: root.batReady ? bat.percentage : 0
    property var batteryTrend: BatteryMath.createTrend()
    property real sampledRate: 0
    property bool historyLoaded: false
    readonly property real batteryRate: root.batReady ? root.sampledRate : 0

    function recordBatteryEnergy(): void {
        const now = Date.now();
        if (!root.batReady) {
            root.batteryTrend = BatteryMath.createTrend();
            root.sampledRate = 0;
            root.historyLoaded = false;
            return;
        }
        if (root.batteryTrend.state !== bat.state || now - root.batteryTrend.time > 90000)
            root.historyLoaded = false;
        root.batteryTrend = BatteryMath.recordEnergy(root.batteryTrend, bat.energy, now, bat.state);
        root.sampledRate = BatteryMath.trendRate(root.batteryTrend, now);
    }

    function requestBatteryHistory(): void {
        if (!root.batReady || root.historyLoaded || batteryHistoryProc.running || !bat.nativePath || (bat.state !== UPowerDeviceState.Charging && bat.state !== UPowerDeviceState.Discharging))
            return;
        batteryHistoryProc.sampleDevice = bat.nativePath;
        batteryHistoryProc.sampleState = bat.state;
        const name = bat.nativePath.split("/").pop().replace(/[^a-zA-Z0-9_]/g, "_");
        batteryHistoryProc.command = ["busctl", "--system", "--json=short", "call", "org.freedesktop.UPower", "/org/freedesktop/UPower/devices/battery_" + name, "org.freedesktop.UPower.Device", "GetHistory", "suu", "charge", "900", "60"];
        batteryHistoryProc.running = true;
    }

    function seedBatteryHistory(text: string): void {
        if (!root.batReady || bat.nativePath !== batteryHistoryProc.sampleDevice || bat.state !== batteryHistoryProc.sampleState)
            return;
        try {
            const now = Date.now();
            const trend = BatteryMath.trendFromHistory(JSON.parse(text).data[0], bat.energy, bat.energyCapacity, bat.percentage, bat.state, now);
            if (BatteryMath.trendRate(trend, now) <= 0)
                return;
            root.batteryTrend = trend;
            root.sampledRate = BatteryMath.trendRate(trend, now);
            root.historyLoaded = true;
        } catch (error) {
            // Unsupported history falls back to continuous local Wh samples.
        }
    }

    function refreshBattery(): void {
        root.recordBatteryEnergy();
        root.requestBatteryHistory();
    }

    onBatChanged: {
        root.batteryTrend = BatteryMath.createTrend();
        root.sampledRate = 0;
        root.historyLoaded = false;
        Qt.callLater(root.refreshBattery);
    }
    Component.onCompleted: Qt.callLater(root.refreshBattery)

    Connections {
        target: root.bat
        function onEnergyChanged(): void { root.recordBatteryEnergy(); }
        function onStateChanged(): void { root.refreshBattery(); }
        function onReadyChanged(): void { root.refreshBattery(); }
    }

    // Keep the trend while the popup is closed, including flat firmware steps.
    Timer {
        interval: 30000
        repeat: true
        running: root.batReady
        onTriggered: root.recordBatteryEnergy()
    }

    Timer {
        interval: 60000
        repeat: true
        running: root.batReady && !root.historyLoaded
        onTriggered: root.requestBatteryHistory()
    }

    Process {
        id: batteryHistoryProc
        property string sampleDevice: ""
        property int sampleState: -1
        stdout: StdioCollector {
            onStreamFinished: root.seedBatteryHistory(text)
        }
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
        if (root.full)
            return "0 W";
        const w = root.batteryRate;
        if (!w || w <= 0.05)
            return "Measuring…";
        return "≈ " + w.toFixed(1) + " W";
    }
    function timeStr(): string {
        if (!root.batReady)
            return "—";
        if (root.full)
            return "Charged";
        if (bat.state === UPowerDeviceState.PendingCharge || bat.state === UPowerDeviceState.PendingDischarge)
            return "Paused";
        if (bat.state !== UPowerDeviceState.Charging && bat.state !== UPowerDeviceState.Discharging)
            return "—";
        // Use the same sustained rate as the watts field, including when UPower
        // briefly reports a large derived rate at a coarse charge-counter step.
        const estimate = BatteryMath.remainingSeconds(bat.energy, bat.energyCapacity, root.batteryRate, root.charging);
        return estimate > 0 ? "≈ " + root.fmtTime(estimate) : "Estimating…";
    }
    function healthStr(): string {
        if (!root.batReady || !bat.healthSupported)
            return "—";
        const health = BatteryMath.healthPercent(bat.healthPercentage);
        return health >= 0 ? health + "%" : "—";
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
            return "Waiting to charge";
        case UPowerDeviceState.PendingDischarge:
            return "Waiting to discharge";
        case UPowerDeviceState.Empty:
            return "Empty";
        default:
            return "—";
        }
    }

    // ---------- sampling (only while open) ----------
    function refresh(): void {
        root.recordBatteryEnergy();
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
        title: "Engine Room"
        icon: "activity"
        onCloseRequested: Globals.engineRoomOpen = false
    }

    GridLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 10 // meters share the header glyph's column
        Layout.rightMargin: 10
        columns: root.cardWidth >= 560 ? 3 : 1
        columnSpacing: 24
        rowSpacing: 24

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: 16

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
                    valColor: root.cpuTemp >= 80 ? root.heatColor((root.cpuTemp - 40) / 50) : Globals.fgColor
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
                        Layout.preferredHeight: 20
                        radius: 2
                        color: Qt.alpha(Globals.fgColor, 0.06)

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

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: 16

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

        ColumnLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.alignment: Qt.AlignTop
            spacing: 16

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
                implicitHeight: 3
                radius: 2
                color: Qt.alpha(Globals.fgColor, 0.08)

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.swapFrac))
                    height: parent.height
                    radius: parent.radius
                    color: root.heatColor(root.swapFrac)
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: batteryBody.implicitHeight + 32
        visible: root.batReady
        radius: 12
        color: Qt.darker(Globals.bgColor, 1.2)

        ColumnLayout {
            id: batteryBody
            anchors.fill: parent
            anchors.margins: 16
            anchors.leftMargin: 10 // same inset as the meters above -> one left edge down the card
            anchors.rightMargin: 10
            spacing: 16

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                MenuIcon {
                    name: "battery"
                    color: Qt.alpha(Globals.fgColor, 0.7)
                }

                Text {
                    text: "Battery"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: 14
                    font.weight: Font.Medium
                }

                Text {
                    Layout.fillWidth: true
                    text: root.stateStr()
                    color: root.charging ? Globals.healthy : Qt.alpha(Globals.fgColor, 0.5)
                    font.family: Globals.textFont.family
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }

                Text {
                    text: root.batPercent + "%"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: 22
                    font.weight: Font.Medium
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 2
                color: Qt.alpha(Globals.fgColor, 0.08)

                Rectangle {
                    width: parent.width * Math.max(0, Math.min(1, root.batFrac))
                    height: parent.height
                    radius: parent.radius
                    color: root.batColor()
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.cardWidth >= 560 ? 4 : 2
                columnSpacing: 20
                rowSpacing: 16

                Repeater {
                    model: [
                        { label: root.charging ? "Charge rate" : "Discharge rate", value: root.rateStr() },
                        { label: root.charging ? "Until full" : "Remaining", value: root.timeStr() },
                        { label: "Health", value: root.healthStr() },
                        { label: "Stored energy", value: root.batReady ? bat.energy.toFixed(1) + " / " + bat.energyCapacity.toFixed(1) + " Wh" : "—" }
                    ]

                    delegate: ColumnLayout {
                        id: batteryStat
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        spacing: 7

                        Text {
                            Layout.fillWidth: true
                            text: batteryStat.modelData.label
                            color: Qt.alpha(Globals.fgColor, 0.45)
                            font.family: Globals.textFont.family
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: batteryStat.modelData.value
                            color: Globals.fgColor
                            font.family: Globals.textFont.family
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }
}
