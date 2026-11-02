import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.osd

// cpu, memory, sound, battery and keep awake live in the system menu; they only reach the rail when one of
// them needs attention -> load past loadWarning, battery low (or charged past batteryFull), output muted,
// keep awake on. Each shows its reading under the icon in its status colour and opens the menu that can fix it
ColumnLayout {
    id: root
    spacing: Globals.railGap

    readonly property bool cpuAlert: Globals.cpuUsage > Globals.loadWarning
    readonly property bool memAlert: Globals.memUsage > Globals.loadWarning
    readonly property bool batteryAlert: Globals.batteryReady && (Globals.batteryCharging ? Globals.batteryPercent >= Globals.batteryFull : Globals.batteryPercent <= Globals.batteryLow)
    readonly property bool muteAlert: OsdState.volMuted

    // an empty layout still reserves a gap next to its neighbours -> only take up space with something to show
    visible: cpuAlert || memAlert || muteAlert || batteryAlert || Globals.caffeinated
    Layout.alignment: Qt.AlignHCenter

    BarButton {
        visible: root.cpuAlert
        menu: "engineRoom"
        active: Globals.engineRoomOpen

        BarValue {
            icon: "cpu"
            text: Globals.cpuUsage + "%"
            tint: Globals.loadTint(Globals.cpuUsage)
        }
    }

    BarButton {
        visible: root.memAlert
        menu: "engineRoom"
        active: Globals.engineRoomOpen

        BarValue {
            icon: "memory"
            text: Globals.memUsage + "%"
            tint: Globals.loadTint(Globals.memUsage)
        }
    }

    BarButton {
        visible: root.muteAlert
        menu: "audio"
        active: Globals.audioMenuOpen

        BarValue {
            icon: "speakerMuted"
            tint: Globals.warningColor
        }
    }

    BarButton {
        visible: root.batteryAlert
        menu: "powerProfiles"
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
