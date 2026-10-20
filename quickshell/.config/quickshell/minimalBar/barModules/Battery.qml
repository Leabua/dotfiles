import Quickshell.Services.UPower
import QtQuick
import qs.templates

BarButton {
    id: root

    readonly property var bat: UPower.displayDevice
    readonly property bool ready: bat != null && bat.ready
    readonly property int percent: ready ? Math.round(bat.percentage * 100) : 0
    // UPower drops out of "Charging" once the battery tops out (FullyCharged) or is trickle-charging (PendingCharge) -> still plugged in, so treat both as charging
    readonly property bool isCharging: ready && (bat.state === UPowerDeviceState.Charging || bat.state === UPowerDeviceState.FullyCharged || bat.state === UPowerDeviceState.PendingCharge)

    visible: ready
    menu: "powerProfiles"
    active: Globals.powerProfilesOpen

    BarValue {
        id: value
        text: root.percent + "%"
        tint: Globals.batteryTint(root.percent, root.isCharging)

        BatteryGlyph {
            anchors.fill: parent
            level: root.percent / 100
            charging: root.isCharging
            color: value.iconColor
            strokeWidth: Globals.barIconStroke
        }
    }

    // the centre island mirrors these while the right island is hidden
    Binding {
        target: Globals
        property: "batteryPercent"
        value: root.percent
    }
    Binding {
        target: Globals
        property: "batteryCharging"
        value: root.isCharging
    }
    Binding {
        target: Globals
        property: "batteryReady"
        value: root.ready
    }
}
