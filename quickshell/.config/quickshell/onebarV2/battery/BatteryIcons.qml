import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts
import qs.defaults

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

    RowLayout {
        id: row
        spacing: Globals.spacing - 3// in-pair gap: icon hugs its value

        BarIcon {
            text: batteryBtn.icon.trim()
            color: batteryBtn.displayColor
            font.pixelSize: Globals.barIconSize
        }
        Text {
            text: batteryBtn.percent + "%"
            color: batteryBtn.displayColor
            font: Globals.textFont
        }
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.powerProfilesOpen = !Globals.powerProfilesOpen
    }
}
