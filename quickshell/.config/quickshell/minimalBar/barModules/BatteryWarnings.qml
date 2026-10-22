pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

import QtQuick

// ----- low-battery notifier: fires warnings through the freedesktop server so they land in the notification centre -----
// 20% -> normal urgency -> yellow heading, auto-dismisses on the standard timeout
// 10% -> critical urgency -> red heading, persists until clicked or charging resumes (dismiss handled in Notifications.qml)
Scope {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    // only "actively draining" counts as discharge -> plugged-in trickle/full states shouldn't fire warnings
    readonly property bool isCharging: bat != null && bat.ready && bat.state !== UPowerDeviceState.Discharging

    property bool warned20: false
    property bool warned10: false

    onPercentChanged: {
        if (bat == null || !bat.ready)
            return;

        if (isCharging) {
            // re-arm both thresholds so the next drain warns again
            warned20 = false;
            warned10 = false;
            return;
        }

        if (percent <= 10 && !warned10) {
            warned10 = true;
            warned20 = true; // skip the low warning if we dropped straight past 20%
            notifyBattery("critical", "Battery critically low", percent + "% remaining." + " " + "Plug in now.");
        } else if (percent <= 20 && !warned20) {
            warned20 = true;
            notifyBattery("normal", "Battery low", percent + "% remaining");
        }

        // re-arm each threshold once we climb back above it
        if (percent > 10)
            warned10 = false;
        if (percent > 20)
            warned20 = false;
    }

    function notifyBattery(urgency: string, summary: string, body: string): void {
        notifyProc.command = ["notify-send", "-a", "Battery", "-u", urgency, summary, body];
        notifyProc.running = true;
    }

    Process {
        id: notifyProc
    }
}
