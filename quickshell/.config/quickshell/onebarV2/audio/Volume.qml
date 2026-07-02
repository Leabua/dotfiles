import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.defaults

Item {
    id: root

    property var sink: Pipewire.defaultAudioSink

    PwObjectTracker {
        objects: [root.sink]
    }

    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int volPercent: ready ? Math.round(sink.audio.volume * 100) : 0

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property string icon: {
        if (!ready)
            return String.fromCodePoint(0xF0581); // if not ready
        if (muted || volPercent === 0)
            return String.fromCodePoint(0xF075F); // if muted or 0
        if (volPercent < 34)
            return String.fromCodePoint(0xF057F); // 1 - 33 - low icon
        if (volPercent < 67)
            return String.fromCodePoint(0xF0580); // 34 - 66 - mid icon
        return String.fromCodePoint(0xF057E); // else high icon
    }
    RowLayout {
        id: row
        spacing: Globals.spacing - 2

        BarIcon {
          text: root.icon
          font.pixelSize: volPercent >= 34 ? Globals.barIconSize : Globals.barIconSize - 8
        }
        Text {
            text: root.volPercent + "%"
            color: Globals.fgColor
            font: Globals.textFont
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.audioMenuOpen = !Globals.audioMenuOpen
    }
}
