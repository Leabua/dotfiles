import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.templates

Item {
    id: batteryBtn

    readonly property var chargingIcons: ["󰢜 ", "󰂆 ", "󰂇 ", "󰂈 ", "󰢝 ", "󰂉 ", "󰢞 ", "󰂊 ", "󰂋 ", "󰂅 "]
    readonly property var defaultIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    readonly property var bat: UPower.displayDevice
    readonly property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    readonly property bool isCharging: bat != null && bat.ready && bat.state === UPowerDeviceState.Charging

    readonly property string icon: {
        if (bat == null || !bat.ready)
            return "󰂃";
        if (bat.state === UPowerDeviceState.FullyCharged || (isCharging && percent === 100))
            return "󰂅 ";
        let idx = Math.min(Math.floor(percent / 10), 9);
        return isCharging ? chargingIcons[idx] : defaultIcons[idx];
    }

    readonly property color displayColor: {
        if (percent <= 10 && !isCharging)
            return Globals.criticalColor;
        if (percent <= 20 && !isCharging)
            return Globals.warningColor;
        if (percent >= 80 && isCharging)
            return Globals.healthy;
        return Globals.fgColor;
    }

    visible: bat != null && bat.ready
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    BarIcon {
        id: row
        icon: batteryBtn.icon
        displayText: batteryBtn.percent + "%"
        color: batteryBtn.displayColor

        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            // onClicked: Globals.powerProfilesOpen = !Globals.powerProfilesOpen
        }
    }
}
