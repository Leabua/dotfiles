pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // default font params
    readonly property font textFont: Qt.font({
        family: "Departure Mono",
        letterSpacing: 0,
        pixelSize: 14,
        weight: 700
    })

    // bar entry icons sit a touch larger than their value text -> one knob to tune -> convenient fix
    readonly property int barIconSize: textFont.pixelSize  

    // global initial initial tick value
    property int tick: 0

    // colors -> material UI colors generated with matugen -> if issue check mutagen config and colour templates
    readonly property alias fgColor: jsonParser.primary
    readonly property alias fgColor2: jsonParser.tertiary
    readonly property color bgColor: "#1e1e1e"

    // readonly property color bgColor: "#000000"
    // readonly property color bgColor: "#1a1a1a"
    readonly property color healthy: "#4fd6be" // green
    readonly property color warningColor: "#f9e2af" // amber
    readonly property color criticalColor: "#f38ba8" // red

    // menu background transparency
    readonly property real menuTransparency: 0.9
    readonly property color menuBg: Qt.alpha(bgColor, menuTransparency)

    //spacing
    readonly property int spacing: 6

    // margins
    readonly property int margins: 10
    readonly property int marginsTop: 6
    readonly property int marginsLeft: 10
    readonly property int marginsRight: 10
    readonly property int marginsBottom: -3

    // borders
    readonly property int borderWidth: 0
    readonly property color borderColor: fgColor

    readonly property int radius: 0 // change to 0 for no rounding -> 8 is the default

    // animation durations -> anchor animations to these instead of inline numbers
    readonly property int animFast: 80
    readonly property int animDuration: 150
    readonly property int animSlow: 250

    // translate mutagen JSON to qml
    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter { 
          id: jsonParser
          //sane defaults in case matugen breaks
          property string primary: "#FFFFFF"
          property string tertiary: "#008080"  
        }
      }
      
    // global timer
    Timer {
        interval: 10000 // 10 seconds -> low = more battery use. Likely minimal but needs to be changed for some laptops
        repeat: true // stop freezing
        running: true // keep it running
        onTriggered: root.tick++ // change event fired every {interval} seconds
    }
}

