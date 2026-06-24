pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// literally just get the properties by passing importing this file and passing Globals.bgColor for background colour as an example
Singleton {
    id: root

    property int currentBarHeight: 0  // track the bar height for centered second order menus else
    readonly property int hyprGaps: 3 // adjust to match the gaps of windows in hyprland so that when the bar is toggled of the 2nd order menus still sit flush with windows

    //second order menus
    property bool powerMenuOpen: false

    // defualt font
    readonly property font textFont: Qt.font({
        family: "SF Pro Display" // Apple Font may need to be downloaded off AUR -> plays nicely with icons
        ,
        letterSpacing: 1,
        pixelSize: 15,
        weight: 700
    })

    // global initial initial tick value
    property int tick: 0

    // colors
    readonly property color bgColor: "#1e1e1e"
    // readonly property color bgColor: "#000000"
    // readonly property color bgColor: "#1a1a1a"
    readonly property color healthy: "#4fd6be" // green
    readonly property color warningColor: "#f9e2af" // amber
    readonly property color criticalColor: "#f38ba8" // red
    // readonly property color bgColor: "#000000"
    // material UI colors generated with matugen -> if issue check mutagen config and colour templates
    readonly property alias fgColor: jsonParser.primary
    readonly property alias fgColor2: jsonParser.tertiary

    //spacing
    readonly property int spacing: 6 // spacing

    // margins
    readonly property int margins: 10
    readonly property int marginsTop: 6
    readonly property int marginsLeft: 10
    readonly property int marginsRight: 10
    readonly property int marginsBottom: -3

    // borders
    readonly property int borderWidth: 1
    readonly property color borderColor: fgColor

    readonly property int radius: 12

    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter { // qmllint disable unresolved-type
            id: jsonParser
            //sane defaults incase matugen breaks
            property string primary: "#FFFFFF"
            property string tertiary: "#008080"  // - no idea what this colour actually produces I just know it helps with debugging
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
