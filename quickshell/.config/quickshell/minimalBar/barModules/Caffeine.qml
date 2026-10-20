import QtQuick
import qs.templates

// steaming cup = session held awake; a cold cup = normal idle / sleep
BarButton {
    iconOnly: true
    onClicked: Globals.toggleCaffeine()

    BarValue {
        icon: Globals.caffeinated ? "coffee" : "cup"
        tint: Globals.caffeinated ? Globals.healthy : Globals.fgColor
    }
}
