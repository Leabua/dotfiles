pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.templates
import "BatteryMath.js" as BatteryMath

import QtQuick

// Shared battery readout for the Engine Room and the battery menu, so both
// show one sustained rate instead of two trends sampled out of step.
Singleton {
    id: root

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

    // Keep the trend while the popups are closed, including flat firmware steps.
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
    function energyStr(): string {
        return root.batReady ? bat.energy.toFixed(1) + " / " + bat.energyCapacity.toFixed(1) + " Wh" : "—";
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
}
