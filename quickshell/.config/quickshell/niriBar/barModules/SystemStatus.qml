import QtQuick
import qs.templates

// niri: one pill for cpu, ram, volume, battery and caffeine -> opens the system menu; the readings
// themselves only reach the bar through CriticalAlerts when one of them needs attention
BarButton {
    menu: "system"
    active: Globals.systemMenuOpen

    BarValue {
        icon: "activity"
    }
}
