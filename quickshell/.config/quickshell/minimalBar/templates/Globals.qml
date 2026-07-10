pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ------- font --------
    readonly property font textFont: Qt.font({
        family: "Departure Mono",
        letterSpacing: 0,
        pixelSize: 14,
        weight: 700
    })

    // bar entry icons sit a touch larger than their value text -> one knob to tune -> convenient fix
    readonly property int barIconSize: textFont.pixelSize
    readonly property int bigIcon: textFont.pixelSize + 28

    // --------- colors -----------------
    //  ~~~~~~ dynamic colors ~~~~~~~
    //  material UI colors generated with matugen
    readonly property alias fgColor: jsonParser.primary
    readonly property alias fgColor2: jsonParser.tertiary

    // translate mutagen JSON to qml
    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonParser
            //sane defaults in case matugen breaks
            property string primary: "#FFFFFF"
            property string tertiary: "#FFFFFF"
        }
    }
    //  ~~~~~~ static colors ~~~~~~~
    readonly property color bgColor: "#1a1a1a"
    // readonly property color bgColor: "#000000"
    // readonly property color bgColor: "#1e1e1e"

    readonly property color healthy: "#4fd6be" // green
    readonly property color warningColor: "#f9e2af" // amber
    readonly property color criticalColor: "#f38ba8" // red

    // menu background transparency
    readonly property real menuTransparency: 0.9
    readonly property color menuBg: Qt.alpha(bgColor, menuTransparency)

    // ---------spacing & layout -----------
    //spacing
    readonly property int spacing: 6

    // margins
    readonly property int margins: 10
    readonly property int marginsTop: 6
    readonly property int marginsLeft: 10
    readonly property int marginsRight: 10
    readonly property int marginsBottom: -3

    // -------- borders and radii ----------
    readonly property int borderWidth: 0
    readonly property color borderColor: fgColor
    readonly property int radius: 8 // change to 0 for no rounding -> 8 is the default

    // ----------  animation durations -----------
    readonly property int animFast: 80
    readonly property int animDuration: 150
    readonly property int animSlow: 250

    // global initial initial tick value + timer
    property int tick: 0

    Timer {
        interval: 10000 // 10 seconds -> low = more battery use. Likely minimal but needs to be changed for some laptops
        repeat: true // stop freezing
        running: true // keep it running
        onTriggered: root.tick++ // change event fired every {interval} seconds
    }
}
