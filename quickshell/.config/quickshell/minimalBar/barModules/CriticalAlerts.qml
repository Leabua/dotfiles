import QtQuick
import QtQuick.Layouts
import qs.templates

// ----- critical metrics surfaced in the centre island while the right cluster is hidden -----
RowLayout {
    id: root
    spacing: Globals.spacing
    visible: !Globals.rightIslandShown

    // ~~~ cpu ~~~
    BarIcon {
        visible: Globals.cpuUsage > 70
        icon: String.fromCodePoint(0xF2DB)
        displayText: Globals.cpuUsage + "%"
        color: Globals.cpuUsage > 85 ? Globals.criticalColor : Globals.warningColor
    }

    // ~~~ ram ~~~
    BarIcon {
        visible: Globals.memUsage > 70
        icon: "󰘚"
        displayText: Globals.memUsage + "%"
        color: Globals.memUsage > 85 ? Globals.criticalColor : Globals.warningColor
    }

    // ~~~ battery: low / critical while draining, or topped up while charging ~~~
    BarIcon {
        visible: Globals.batteryReady && ((Globals.batteryPercent <= 20 && !Globals.batteryCharging) || (Globals.batteryPercent >= 80 && Globals.batteryCharging))
        icon: Globals.batteryCharging ? "󰂅" : (Globals.batteryPercent <= 10 ? String.fromCodePoint(0xF244) : String.fromCodePoint(0xE0B1))
        displayText: Globals.batteryPercent + "%"
        color: (Globals.batteryPercent <= 10 && !Globals.batteryCharging) ? Globals.criticalColor : (Globals.batteryPercent <= 20 && !Globals.batteryCharging) ? Globals.warningColor : Globals.healthy
    }
}
