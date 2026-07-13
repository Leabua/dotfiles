import QtQuick
import QtQuick.Layouts
import qs.templates

// ----- critical metrics surfaced in the centre island while the right cluster is hidden -----
RowLayout {
    id: root
    spacing: Globals.spacing

    readonly property bool cpuAlert: Globals.cpuUsage > 70
    readonly property bool memAlert: Globals.memUsage > 70
    readonly property bool batteryAlert: Globals.batteryReady && ((Globals.batteryPercent <= 20 && !Globals.batteryCharging) || (Globals.batteryPercent >= 80 && Globals.batteryCharging))

    // an empty RowLayout still reserves a spacing gap next to its neighbours -> only take up space when there's something to show
    visible: !Globals.rightIslandShown && (cpuAlert || memAlert || batteryAlert)

    // ~~~ cpu ~~~
    BarIcon {
        visible: root.cpuAlert
        icon: String.fromCodePoint(0xF2DB)
        displayText: Globals.cpuUsage + "%"
        color: Globals.cpuUsage > 85 ? Globals.criticalColor : Globals.warningColor
    }

    // ~~~ ram ~~~
    BarIcon {
        visible: root.memAlert
        icon: "󰘚"
        displayText: Globals.memUsage + "%"
        color: Globals.memUsage > 85 ? Globals.criticalColor : Globals.warningColor
    }

    // ~~~ battery: low / critical while draining, or topped up while charging ~~~
    BarIcon {
        visible: root.batteryAlert
        icon: Globals.batteryCharging ? "󰂅" : (Globals.batteryPercent <= 10 ? "󰁺" : "󰁻")
        displayText: Globals.batteryPercent + "%"
        color: (Globals.batteryPercent <= 10 && !Globals.batteryCharging) ? Globals.criticalColor : (Globals.batteryPercent <= 20 && !Globals.batteryCharging) ? Globals.warningColor : Globals.healthy
    }
}
