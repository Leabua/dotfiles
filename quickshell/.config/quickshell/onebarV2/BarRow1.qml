import QtQuick
import QtQuick.Layouts
import qs.audio
import qs.battery
import qs.defaults
import qs.power
import qs.sysUtils

RowLayout {
    id: root
    property int barLvl
    spacing: Globals.spacing + 4
    // Use shown: false to have it gone forever and true to always have it there
    Reveal {
        shown: false
        Logo {
            id: logo
        }
    }
    Reveal {
        shown: root.barLvl >= 2
        Clock {
            id: clock
        }
    }
    Reveal {
        shown: root.barLvl >= 1
        Workspaces {
            id: ws
        }
    }
    Reveal {
        shown: root.barLvl >= 3
        Network {
            id: network
        }
    }
    Reveal {
        shown: root.barLvl >= 3
        CPU {
            id: cpu
        }
    }
    Reveal {
        shown: root.barLvl >= 3 || memory.memoryUsage >= 75
        Memory {
            id: memory
        }
    }
    Reveal {
        shown: root.barLvl >= 3
        Volume {
            id: volume
        }
    }
    Reveal {
        shown: root.barLvl >= 3 || (battery.percent <= 20 && !battery.isCharging) || (battery.isCharging && battery.percent >= 80)
        BatteryIcons {
            id: battery
        }
    }
    Reveal {
        shown: root.barLvl >= 3
        PowerBtn {
            id: powerBtn
        }
    }
}
