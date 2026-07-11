import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.barModules

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + Globals.padding
    implicitHeight: row.implicitHeight === 0 ? 0 : row.implicitHeight + Globals.vertPadding

    color: Globals.bgColor
    radius: Globals.textFont / 2
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
