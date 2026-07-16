pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    // the ShellScreen Hyprland currently has focused -> lets toasts / popups follow the active monitor
    readonly property var focusedScreen: {
        const m = Hyprland.focusedMonitor;
        if (!m)
            return null;
        for (const s of Quickshell.screens)
            if (s.name === m.name)
                return s;
        return null;
    }

    // ------- font --------
    readonly property font textFont: Qt.font({
        // family: "DepartureMono Nerd Font",
        family: "Maple Mono NF",
        letterSpacing: 0,
        pixelSize: 14,
        weight: 700
    })

    // bar entry icons sit a touch larger than their value text -> one knob to tune -> convenient fix
    readonly property int barIconSize: textFont.pixelSize + 2
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
    readonly property int padding: spacing * 2
    readonly property int vertPadding: spacing * 2 - 6
    readonly property int horiPadding: spacing * 2 + 5

    // margins
    readonly property int margins: 10
    readonly property int marginsTop: 7
    readonly property int marginsLeft: 9
    readonly property int marginsRight: 9
    readonly property int marginsBottom: -4

    // -------- borders and radii ----------
    readonly property int borderWidth: 0
    readonly property color borderColor: fgColor
    readonly property int radius: 8 // change to 0 for no rounding -> 8 is the default

    // ----------  animation durations -----------
    readonly property int animFast: 80
    readonly property int animDuration: 150
    readonly property int animSlow: 250

    // ---------- menu open-state ----------
    // bar-icon clicks and the matching IPC handlers toggle these; the menus mounted
    // from menus/ listen and show / hide their PopupWindow accordingly
    property bool wifiMenuOpen: false
    property bool audioMenuOpen: false
    property string audioMenuView: "audio" // "audio" | "bluetooth" -> which card the audio menu shows
    property bool engineRoomOpen: false
    property bool powerProfilesOpen: false
    property bool powerMenuOpen: false
    property bool remindersOpen: false

    // ---------- menu positioning support ----------
    property int currentBarHeight: 0  // mirrored from shell.qml so centered menus sit just below the bar
    property bool barShown: true       // minimalBar is always shown; kept so ported menus' show / hide maths resolve
    readonly property int hyprGaps: 3  // match hyprland window gaps so menus sit flush with tiled windows
    readonly property int cardY: 24    // vertical nudge applied to menu cards under the bar
    readonly property bool headerIcons: true // flip to preview menu headers with / without their glyph
    readonly property bool buttonIcons: true // flip to preview menu buttons with / without their glyph

    // scene-x of the bar button that opened the current menu -> menus anchor their card under it (-1 = centered)
    property real menuAnchorX: -1

    // screen rect of the open menu card -> lets the toasts duck below a menu sitting in their spot (zero-width = nothing open)
    property rect menuCardRect: Qt.rect(0, 0, 0, 0)

    // ~~~ right-island critical mirror -> surfaced in the centre island when the right cluster is hidden ~~~
    property bool rightIslandShown: true
    property int cpuUsage: 0
    property int memUsage: 0
    property int batteryPercent: 100
    property bool batteryCharging: false
    property bool batteryReady: false

    // ----- one bar menu open at a time; clicking another bar icon switches -----
    function toggleMenu(name) {
        const wasOpen = (name === "wifi" && wifiMenuOpen) || (name === "audio" && audioMenuOpen) || (name === "engineRoom" && engineRoomOpen) || (name === "powerProfiles" && powerProfilesOpen) || (name === "powerMenu" && powerMenuOpen);
        wifiMenuOpen = false;
        audioMenuOpen = false;
        engineRoomOpen = false;
        powerProfilesOpen = false;
        powerMenuOpen = false;
        if (!wasOpen) {
            if (name === "wifi")
                wifiMenuOpen = true;
            else if (name === "audio")
                audioMenuOpen = true;
            else if (name === "engineRoom")
                engineRoomOpen = true;
            else if (name === "powerProfiles")
                powerProfilesOpen = true;
            else if (name === "powerMenu")
                powerMenuOpen = true;
        }
    }

    // global initial initial tick value + timer
    property int tick: 0

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: root.tick++
    }
}
