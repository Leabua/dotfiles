import Quickshell.Services.UPower
import QtQuick
import qs

Item {
    id: batteryBtn

    property var chargingIcons: ["󰢜 ", "󰂆 ", "󰂇 ", "󰂈 ", "󰢝 ", "󰂉 ", "󰢞 ", "󰂊 ", "󰂋 ", "󰂅 "]
    property var defaultIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    property var bat: UPower.displayDevice
    property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    property bool isCharging: bat != null && bat.ready && bat.state === UPowerDeviceState.Charging
    property bool isCritical: bat != null && bat.ready && !isCharging && percent <= 20

    property string icon: {
        if (bat == null || !bat.ready)
            return "";
        if (bat.state === UPowerDeviceState.FullyCharged || (isCharging && percent === 100))
            return "󰂅 ";
        let idx = Math.min(Math.floor(percent / 10), 9);
        return isCharging ? chargingIcons[idx] : defaultIcons[idx];
    }

    property color displayColor: {
        if (percent <= 10 && !isCharging)
            return Globals.criticalColor;
        if (percent <= 20 && !isCharging)
            return Globals.warningColor;
        if (percent >= 80)
            return Globals.healthy;
        return Globals.fgColor;
    }

    visible: bat != null && bat.ready
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    Text {
        id: row
        text: batteryBtn.icon + batteryBtn.percent + "%"
        color: batteryBtn.displayColor
        font: Globals.textFont
    }
}
