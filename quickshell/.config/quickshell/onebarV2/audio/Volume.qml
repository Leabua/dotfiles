import Quickshell.Services.Pipewire
import QtQuick
import qs.defaults

Item {
    id: root

    property var sink: Pipewire.defaultAudioSink

    // getting some properties ready
    readonly property bool ready: sink && sink.ready
    readonly property bool muted: ready && sink.audio.muted
    readonly property int volPercent: ready ? Math.round(sink.audio.volume * 100) : 0

    //need width and height for bar to dynamically calculate size
    implicitWidth: textId.implicitWidth
    implicitHeight: textId.implicitHeight

    // how we get our icons to math
    // using nerd font icon codes - saneAspect video on youtube
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
    // styling the text
    Text {
        id: textId
        text: root.icon + " " + root.volPercent + "%"
        color: Globals.fgColor
        font: Globals.textFont
    }
    // what actually checks the vol percent changes
}
