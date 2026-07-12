import Quickshell.Services.UPower
import QtQuick
import qs.templates

Item {
    id: batteryBtn

    // ~~~ mdi battery-charging keeps the bolt-in-battery look (fa's is pro-gated) ~~~
    readonly property var chargingIcons: ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]

    readonly property var bat: UPower.displayDevice
    readonly property int percent: (bat != null && bat.ready) ? Math.round(bat.percentage * 100) : 0
    readonly property bool isCharging: bat != null && bat.ready && bat.state === UPowerDeviceState.Charging

    // ----- fa battery on discharge, mdi bolt while charging -----
    readonly property string icon: {
        if (bat == null || !bat.ready)
            return String.fromCodePoint(0xF244);
        if (isCharging)
            return chargingIcons[Math.min(Math.floor(percent / 10), 9)];
        if (percent > 87)
            return String.fromCodePoint(0xF240);
        if (percent > 62)
            return String.fromCodePoint(0xF241);
        if (percent > 37)
            return String.fromCodePoint(0xF242);
        if (percent > 12)
            return String.fromCodePoint(0xE0B1);
        return String.fromCodePoint(0xF244);
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
        onClicked: {
            Globals.menuAnchorX = batteryBtn.mapToItem(null, batteryBtn.width / 2, 0).x;
            Globals.toggleMenu("powerProfiles");
        }
    }
}
