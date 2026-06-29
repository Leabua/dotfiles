pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

import QtQuick


Scope {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    readonly property bool isCharging: bat != null && bat.ready && bat.state === UPowerDeviceState.Charging

    property bool warned20: false
    property bool warned10: false

    onPercentChanged: {
        if (bat == null || !bat.ready)
            return;

        if (isCharging) {
            warned20 = false;
            warned10 = false;
            return;
        }

        if (percent <= 10 && !warned10) {
            warned10 = true;
            notifyBattery("critical", "Battery critically low — plug in now");
        } else if (percent <= 20 && !warned20) {
            warned20 = true;
            notifyBattery("normal", "Battery low");
        }

        // re-arm each threshold once we climb back above it
        if (percent > 10)
            warned10 = false;
        if (percent > 20)
            warned20 = false;
    }

    function notifyBattery(urgency: string, summary: string): void {
        notifyProc.command = ["notify-send", "-a", "Battery", "-u", urgency, summary, root.percent + "% remaining"];
        notifyProc.running = true;
    }

    Process {
        id: notifyProc
    }
}
