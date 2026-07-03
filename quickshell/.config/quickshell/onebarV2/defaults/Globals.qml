pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// the single source of truth for most variables -> prevents having to think about what to use
Singleton {
    id: root

    // the ShellScreen Hyprland currently has focused -> lets toasts (and any popup that opts in) follow the active monitor instead of landing on a fixed one
    readonly property var focusedScreen: {
        const m = Hyprland.focusedMonitor;
        if (!m)
            return null;
        for (const s of Quickshell.screens)
            if (s.name === m.name)
                return s;
        return null;
    }

    // default font params
    readonly property font textFont: Qt.font({
        // family: "Departure Mono,Iosevka Nerd Font, JetBrainsMono Nerd Font, SF Pro Display",
        family: "Departure Mono",
        letterSpacing: 0,
        pixelSize: 14 // -> this is what you use to make things compact
        ,
        weight: 700
    })

    // bar entry glyphs sit a touch larger than their value text -> one knob to tune
    readonly property int barIconSize: textFont.pixelSize + 8

    // orientation
    property int currentBarHeight: 0  // track the bar height for centered second order menus else
    readonly property int hyprGaps: 3 // adjust to match the gaps of windows in hyprland so that when the bar is toggled of the 2nd order menus still sit flush with windows
    readonly property int padding: 14
    readonly property int cardY: 24

    //conditions
    property bool barShown: true      // shell.qml mirrors its bar state here so centered menus can shift up when the bar is hidden
    property bool powerMenuOpen: false
    property bool powerProfilesOpen: false
    property bool audioMenuOpen: false        // one popup hosts both the audio + bluetooth cards
    property string audioMenuView: "audio"    // which card is showing: "audio" | "bluetooth"
    property bool wifiMenuOpen: false         // standalone wifi card (opened from the Network bar entry)
    property bool remindersOpen: false        // reminders / kanban panel (opened via the "reminders" IPC handler)

    // global initial initial tick value
    property int tick: 0

    // colors
    // material UI colors generated with matugen -> if issue check mutagen config and colour templates
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

    readonly property int radius: 8 // change to 0 for no rounding

    // animation durations -> anchor animations to these instead of inline numbers
    readonly property int animFast: 80
    readonly property int animDuration: 150
    readonly property int animSlow: 250

    // bar show/hide collapse speed -> single knob for the whole toggle animation
    readonly property int barCollapse: 200

    // icon visibility toggles -> flip to preview menus with/without icons (BarRow1 untouched)
    readonly property bool headerIcons: true
    readonly property bool buttonIcons: true

    // translate mutagen JSON to qml
    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter { // qmllint disable unresolved-type
            id: jsonParser
            //sane defaults in case matugen breaks
            property string primary: "#FFFFFF"
            property string tertiary: "#008080"  // - no idea what this colour actually produces I just know it helps with debugging
        }
    }

    // global timer
    Timer {
        interval: 10000 // 10 seconds -> set not too low that it makes icons useless and not too high since it likely chops battery
        repeat: true // stop freezing
        running: true // keep it running
        onTriggered: root.tick++ // change event fired every {interval} seconds
    }
}
