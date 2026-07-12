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
        spacing: Globals.spacing
        Logo {} // -> new access point for power settings
        Clock {}
        Workspaces {}
        CriticalAlerts {} // battery / cpu / ram alerts when the right island is hidden
    }
}
