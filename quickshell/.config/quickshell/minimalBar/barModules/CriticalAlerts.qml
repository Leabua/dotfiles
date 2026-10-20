import QtQuick
import QtQuick.Layouts
import qs.templates

// ----- readings worth seeing, surfaced in the centre island while the right island is hidden -----
// the menus open centred (anchorToButton: false) rather than snapping to the right edge like the right island does
RowLayout {
    id: root
    spacing: 0

    readonly property bool cpuAlert: Globals.cpuUsage > Globals.loadWarning
    readonly property bool memAlert: Globals.memUsage > Globals.loadWarning
    readonly property bool batteryAlert: Globals.batteryReady && (Globals.batteryCharging ? Globals.batteryPercent >= Globals.batteryFull : Globals.batteryPercent <= Globals.batteryLow)

    // an empty RowLayout still reserves a spacing gap next to its neighbours -> only take up space when there's something to show
    visible: !Globals.rightIslandShown && (cpuAlert || memAlert || batteryAlert || Globals.caffeinated)

    BarButton {
        visible: root.cpuAlert || root.memAlert
        menu: "engineRoom"
        anchorToButton: false
        active: Globals.engineRoomOpen

        BarValue {
            visible: root.cpuAlert
            icon: "cpu"
            text: Globals.cpuUsage + "%"
            tint: Globals.loadTint(Globals.cpuUsage)
        }
        BarValue {
            visible: root.memAlert
            icon: "memory"
            text: Globals.memUsage + "%"
            tint: Globals.loadTint(Globals.memUsage)
        }
    }

    BarButton {
        visible: root.batteryAlert
        menu: "powerProfiles"
        anchorToButton: false
        active: Globals.powerProfilesOpen

        BarValue {
            id: battery
            text: Globals.batteryPercent + "%"
            tint: Globals.batteryTint(Globals.batteryPercent, Globals.batteryCharging)

            BatteryGlyph {
                anchors.fill: parent
                level: Globals.batteryPercent / 100
                charging: Globals.batteryCharging
                color: battery.iconColor
                strokeWidth: Globals.barIconStroke
            }
        }
    }

    BarButton {
        visible: Globals.caffeinated
        onClicked: Globals.toggleCaffeine()

        BarValue {
            icon: "coffee"
            tint: Globals.healthy
        }
    }
}
