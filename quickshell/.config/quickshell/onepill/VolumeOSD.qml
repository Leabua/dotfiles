pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: osdLayout
    spacing: 6
    implicitWidth: 120
    implicitHeight: 12

    property color fgColor: "#FFFFFF"

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink

    Text {
        text: {
            if (!defaultSink || !defaultSink.audio) return "󰕿";
            if (defaultSink.audio.muted) return "󰝟";
            let vol = Math.round(defaultSink.audio.volume * 100);
            if (vol >= 50) return "󰕾";
            if (vol > 0) return "󰖀";
            return "󰕿";
        }
        font.family: global.shellFont.family
        font.pixelSize: 11
        font.bold: true
        color: osdLayout.fgColor
        Layout.alignment: Qt.AlignVCenter
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 80
        implicitHeight: 4
        radius: 2
        color: Qt.rgba(osdLayout.fgColor.r, osdLayout.fgColor.g, osdLayout.fgColor.b, 0.15)

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            implicitWidth: parent.width * (defaultSink && defaultSink.audio ? defaultSink.audio.volume : 0)
            radius: 2
            color: osdLayout.fgColor
        }
    }
}
