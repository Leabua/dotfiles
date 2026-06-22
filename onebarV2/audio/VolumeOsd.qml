import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs

Item {
    id: root

    property var sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink && sink.ready
    readonly property real volume: ready ? (sink.audio.volume ?? 0) : 0

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    PwObjectTracker {
        objects: root.sink
    }

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: 8

        Text {
            text: root.volume === 0 ? "󰝟 " : root.volume < 0.34 ? "󰕿 " : root.volume < 0.67 ? "󰖀 " : "󰕾 "
            color: Globals.fgColor
            font: Globals.textFont
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 6
            radius: 3
            color: Qt.alpha(Globals.fgColor, 0.2)

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                implicitWidth: parent.width * root.volume
                radius: parent.radius
                color: Globals.fgColor

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 80
                    }
                }
            }
        }
    }
}
