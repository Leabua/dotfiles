import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.barModules

Rectangle {
    id: root
    implicitWidth: Math.max(row.implicitWidth, 300)
    implicitHeight: row.implicitHeight
    color: Globals.fgColor
    radius: Globals.textFont.pixelsize / 2
    RowLayout {
        id: row
        spacing: Globals.spacing / 2
        Logo {} // -> new access point for power settings
        Clock {}
        Workspaces {}  // -> making this the entry point for the engine room
    }
}
