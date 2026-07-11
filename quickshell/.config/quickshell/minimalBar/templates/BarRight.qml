import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.barModules

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + Globals.horiPadding
    implicitHeight: row.implicitHeight + Globals.vertPadding
    color: Globals.bgColor
    radius: implicitHeight / 2

    RowLayout {
        id: row
        anchors.centerIn: parent
        CPU {} // conditional logic -> cpu crit states
        Memory {} // conditional logic -> mem crit states
        Volume {}
        Battery {} //conditional logic -> battery crit states
        Wifi {} //conditional logic -> when the wifi is off copletley  bringup

    }
}
