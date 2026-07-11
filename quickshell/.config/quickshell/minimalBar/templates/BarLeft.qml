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
        /*
         volumeOSD{}
         brightnessOSD{}
         playerCTLStyleScript{} -> refer to dotfiles waybar
        */
    }
}
