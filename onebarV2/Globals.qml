pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// literally just get the properties by passing importing this file and passing Globals.bgColor for example
Singleton {
    id: root
    // bar font
    property font textFont: Qt.font({
        family: "SF Pro Display",
        letterSpacing: 1,
        pixelSize: 15,
        weight: 700
    })

    // initial tick value
    property int tick: 0

    property color bgColor: "#1a1a1a"
    // material UI colors generated with matugen -> if issue check mutagen config and colour templates
    property alias fgColor: jsonParser.primary
    property alias fgColor2: jsonParser.tertiary

    property color healthy: "#4fd6be" // green
    property color warningColor: "#f9e2af" // amber
    property color criticalColor: "#f38ba8" // red

    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter { // qmllint disable unresolved-type
            id: jsonParser
            //sane defaults incase matugen breaks
            property string primary: "#FFFFFF"
            property string tertiary: "#EEEFFF"  // - no idea what this colour actually produces I just no it helps with debugging
        }
    }
    // global timer
    Timer {
        interval: 10000 // 10 seconds -> set not to low that it makes icons useless and not too high since it likely chops battery
        repeat: true // stop freezing
        running: true // keep it running
        onTriggered: root.tick++ // change event fired every {interval} seconds
    }
}
