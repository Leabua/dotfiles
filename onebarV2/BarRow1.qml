import QtQuick
import QtQuick.Layouts
import qs.audio
import qs.battery
import qs.defaults
import qs.sysUtils

RowLayout {
    id: root
    property int barLvl
    spacing: Globals.spacing
    // Use shown: false to have it gone forever and true to always have it there
    Reveal {
        shown: false
        Logo {}
    }
    Reveal {
        shown: root.barLvl >= 2
        Clock {}
    }
    Reveal {
        shown: root.barLvl >= 1
        Workspaces {}
    }
    Reveal {
        shown: root.barLvl >= 3
        CPU {}
    }
    Reveal {
        shown: root.barLvl >= 3 || memory.memoryUsage >= 75
        Memory {
            id: memory
        }
    }
    Reveal {
        shown: root.barLvl >= 3
        Network {}
    }
    Reveal {
        shown: root.barLvl >= 3
        Volume {}
    }
    Reveal {
        shown: root.barLvl >= 3 || (battery.percent <= 20 && !battery.isCharging) || (battery.isCharging && battery.percent >= 80)
        BatteryIcons {
            id: battery
        }
    }
    Reveal {
        shown: root.barLvl >= 3
        PowerButton {}
    }
}
