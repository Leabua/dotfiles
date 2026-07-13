import Quickshell.Services.UPower
import QtQuick
import qs.templates

Item {
    id: batteryBtn

    // mdi battery glyphs (matches onebarV2)
    readonly property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property var defaultIcons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]

    readonly property var bat: UPower.displayDevice
    readonly property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    // UPower drops out of "Charging" once the battery tops out (FullyCharged) or is trickle-charging (PendingCharge) -> still plugged in, so treat both as charging
    readonly property bool isCharging: bat != null && bat.ready && (bat.state === UPowerDeviceState.Charging || bat.state === UPowerDeviceState.FullyCharged || bat.state === UPowerDeviceState.PendingCharge)

    // ----- mdi battery on discharge, mdi charging glyphs while charging -----
    readonly property string icon: {
        if (bat == null || !bat.ready)
            return "󰂃";
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

    Binding {
        target: Globals
        property: "batteryPercent"
        value: batteryBtn.percent
    }
    Binding {
        target: Globals
        property: "batteryCharging"
        value: batteryBtn.isCharging
    }
    Binding {
        target: Globals
        property: "batteryReady"
        value: batteryBtn.bat != null && batteryBtn.bat.ready
    }

    visible: bat != null && bat.ready
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    BarIcon {
        id: content
        icon: batteryBtn.icon
        displayText: batteryBtn.percent + "%"
        color: batteryBtn.displayColor
    }
    MouseArea {
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor
        // all this is so that I can be bale to click outside the bar on other buttons but need a more elegant fix
        onClicked: {
            Globals.menuAnchorX = batteryBtn.mapToItem(null, batteryBtn.width / 2, 0).x;
            Globals.toggleMenu("powerProfiles");
        }
    }
}
