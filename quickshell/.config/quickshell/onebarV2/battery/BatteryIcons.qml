import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.defaults

Item {
    id: batteryBtn

    property var chargingIcons: ["󰢜 ", "󰂆 ", "󰂇 ", "󰂈 ", "󰢝 ", "󰂉 ", "󰢞 ", "󰂊 ", "󰂋 ", "󰂅 "]
    property var defaultIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    property var bat: UPower.displayDevice
    property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    property bool isCharging: bat != null && bat.ready && bat.state === UPowerDeviceState.Charging

    property string icon: {
        if (bat == null || !bat.ready)
            return "󰂃";
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
        if (percent >= 80 && isCharging)
            return Globals.healthy;
        return Globals.fgColor;
    }

    // magic
    // low-battery notifications: fire once per downward crossing while discharging, so I get warned (even fullscreen) at 20% and again at 10%
    // -> stops the annoyance of fullscreening an app and never knowing if my battery is about to die or not
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
        notifyProc.command = ["notify-send", "-a", "Battery", "-u", urgency, summary, batteryBtn.percent + "% remaining"];
        notifyProc.running = true;
    }
    Process {
        id: notifyProc
    }
    //end of magic

    visible: bat != null && bat.ready
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    RowLayout {
        id: row
        spacing: Globals.spacing - 3// in-pair gap: icon hugs its value

        BarIcon {
            text: batteryBtn.icon.trim()
            color: batteryBtn.displayColor
            font.pixelSize: batteryBtn.isCharging ? Globals.barIconSize : Globals.barIconSize - 6
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
