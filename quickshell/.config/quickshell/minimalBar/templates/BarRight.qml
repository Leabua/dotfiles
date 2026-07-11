import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.barModules

Rectangle {
    id: root
    implicitWidth: Math.max(row.implicitWidth, 300)
    implicitHeight: row.implicitHeight
    color: "transparent"
    radius: Globals.textFont.pixelsize / 2

    RowLayout {
        id: row
        spacing: Globals.spacing + 1
        Cpu {} // conditional logic -> cpu crit states
        Memory {} // conditional logic -> mem crit states
        Volume {}
        Battery {} //conditional logic -> battery crit states
        Wifi {} //conditional logic -> when the wifi is off copletley  bringup

    }
}
