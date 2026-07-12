import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.barModules
import qs.osd

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + Globals.horiPadding
    implicitHeight: row.implicitHeight === 0 ? 0 : row.implicitHeight + Globals.vertPadding

    color: Globals.bgColor
    radius: implicitHeight / 2
    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Globals.spacing / 2

        // only one of these is ever visible -> they swap in place (OsdState.active)
        VolumeOSD {}
        BrightnessOSD {}
        MediaScriptOSD {} // playerctl style now playing -> from dotfiles waybar media.sh
    }
}
