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
    property alias fgColor: jsonParser.primary
    property alias fgColor2: jsonParser.tertiary

    property color healthy: "#4fd6be" // green
    property color warningColor: "#f9e2af" // amber
    property color criticalColor: "#f38ba8" // red

    // material colors generated with matugen
    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonParser
            //sane defaults incase matugen breaks
            property string primary: "#FFFFFF"
            property string tertiary: "#EEFFFF"
        }
    }
    // global timer
    Timer {
        interval: 5000 // 5 seconds
        repeat: true // stop freezing
        running: true // keep it running
        onTriggered: root.tick++ // change event fired every {interval} seconds
    }
}
