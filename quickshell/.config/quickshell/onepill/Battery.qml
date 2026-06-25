pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.UPower
import QtQuick

StatusButton {
    id: batBtn

    property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    property var defaultIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    property var bat: UPower.displayDevice

    property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    property bool isCharging: bat != null && bat.ready && bat.state === UPowerDeviceState.Charging
    property bool isCritical: bat != null && bat.ready && !isCharging && percent <= 20

    visible: bat != null && bat.ready

    icon: {
        if (bat == null || !bat.ready)
            return "";
        if (bat.state === UPowerDeviceState.FullyCharged || (isCharging && percent === 100))
            return "󰂅";
        let idx = Math.min(Math.floor(percent / 10), 9);
        return isCharging ? chargingIcons[idx] : defaultIcons[idx];
    }

    label: percent + "%"
    isActive: true

    fgColor: {
        if (percent <= 10 && !isCharging)
            return "#f38ba8";
        if (percent <= 20 && !isCharging)
            return "#f9e2af";
        return "#FFFFFF";
    }

    Behavior on fgColor {
        ColorAnimation {
            duration: 60
        }
    }
}
