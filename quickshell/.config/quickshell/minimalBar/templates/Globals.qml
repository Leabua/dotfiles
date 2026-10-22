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
        // family: "Maple Mono NF",
        family: "SF Pro Display",
        letterSpacing: 0,
        pixelSize: 16,
        weight: 700
    })

    // ------- bar --------
    // the bar speaks the menus' language: semibold values, line icons dimmed one tier below them
    readonly property font barFont: Qt.font({
        family: textFont.family,
        pixelSize: 15,
        weight: Font.DemiBold,
        features: { "tnum": 1 } // tabular digits -> 9% -> 10% doesn't shove the island sideways
    })
    readonly property int barIconSize: 16
    readonly property real barIconStroke: 1.5 // a touch heavier than the menus' 1.7 so 16px icons hold up next to semibold text
    readonly property real barIconAlpha: 0.9 // same tier as the menu rows' icons
    readonly property int barItemHeight: 22 // hover / open pill around each bar entry
    readonly property int barItemPadding: 6 // pill's horizontal padding
    readonly property int barGlyphGap: 4 // icon -> value, and neighbours that read as one unit (logo, clock, workspaces)
    readonly property int barIslandInset: 2 // pill -> island top / bottom edge, so the two radii nest
    readonly property int barIslandSidePadding: 6 // pill -> island left / right end; roomier than the inset so the ends breathe
    readonly property int barIslandHeight: barItemHeight + barIslandInset * 2
    readonly property int barIslandRadius: 11 // a touch squarer than a full pill (13)
    readonly property int barItemRadius: barIslandRadius - barIslandInset // concentric with the island's corners

    // --------- colors -----------------
    //  ~~~~~~ dynamic colors ~~~~~~~
    //  material UI colors generated with matugen
    readonly property alias fgColor: jsonParser.primary
    readonly property alias fgColor2: jsonParser.tertiary
    // readonly property color fgColor: "#FFFFFF"
    // readonly property color fgColor2: "#FFFFFF"

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
    // readonly property color bgColor: "#000000"
    readonly property color bgColor: "#1a1a1a"
    // readonly property color bgColor: "#1e1e1e"

    readonly property color healthy: "#4fd6be" // green
    readonly property color warningColor: "#f9e2af" // amber
    readonly property color criticalColor: "#f38ba8" // red

    // menu background transparency
    readonly property real menuTransparency: 0.96
    readonly property color menuBg: Qt.alpha(bgColor, menuTransparency)

    // ---------spacing & layout -----------
    readonly property int spacing: 6

    // bar window margins against the screen edge; the negative bottom pulls tiled windows up under the islands
    readonly property int margins: 10 // default card padding + bottom clearance for menus
    readonly property int marginsTop: 4
    readonly property int marginsLeft: 8
    readonly property int marginsRight: 8
    readonly property int marginsBottom: -3

    // -------- borders and radii ----------
    readonly property int borderWidth: 0
    readonly property color borderColor: fgColor
    readonly property int radius: 16 // change to 0 for no rounding -> 8 is the default

    // ----------  animation durations -----------
    readonly property int animFast: 80
    readonly property int animDuration: 150
    readonly property int animPress: 120 // press feedback (scale-down on click)
    // strong ease-out: responds instantly, lands softly -> use for anything entering or unfolding
    readonly property var easeOut: [0.23, 1, 0.32, 1, 1, 1]

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
    property var activePopup: null
    property var barWindows: [] // panels allowed to receive input while a popup owns focus
    property bool popupClickThrough: false // enabled after the compositor observer is installed

    function dismissPopup(): void {
        if (activePopup)
            activePopup.dismissed();
    }

    // ---------- menu positioning support ----------
    readonly property int currentBarHeight: barIslandHeight // menus sit just below the bar
    property bool barShown: true       // mirrored from shell.qml -> menus slide up to the top edge while the bar is hidden
    readonly property int hyprGaps: 4  // match hyprland window gaps so menus sit flush with tiled windows
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

    // ----- status thresholds: the right island and the centre-island alerts read the same numbers -----
    readonly property int loadWarning: 70
    readonly property int loadCritical: 85
    readonly property int batteryLow: 20
    readonly property int batteryCritical: 10
    readonly property int batteryFull: 80 // charging past this turns the battery green

    function loadTint(percent: int): color {
        if (percent > loadCritical)
            return criticalColor;
        if (percent > loadWarning)
            return warningColor;
        return fgColor;
    }

    function batteryTint(percent: int, charging: bool): color {
        if (charging)
            return percent >= batteryFull ? healthy : fgColor;
        if (percent <= batteryCritical)
            return criticalColor;
        if (percent <= batteryLow)
            return warningColor;
        return fgColor;
    }

    // ----- one bar menu open at a time; clicking another bar icon switches -----
    readonly property var barMenus: ({
            wifi: "wifiMenuOpen",
            audio: "audioMenuOpen",
            engineRoom: "engineRoomOpen",
            powerProfiles: "powerProfilesOpen",
            powerMenu: "powerMenuOpen"
        })

    function toggleMenu(name: string): void {
        const wasOpen = root[barMenus[name]];
        for (const key in barMenus)
            root[barMenus[key]] = false;
        if (!wasOpen)
            root[barMenus[name]] = true;
    }

    // ---------- caffeine ----------
    // off by default; re-enabled manually each session (not persisted across restarts)
    property bool caffeinated: false

    function toggleCaffeine(): void {
        caffeinated = !caffeinated;
        caffeineNotify.command = ["notify-send", "-a", "Caffeine", caffeinated ? "Caffeine on" : "Caffeine off", caffeinated ? "Session will stay awake" : "Session can sleep"];
        caffeineNotify.running = true;
    }

    // hypridle honours logind idle/sleep inhibitors -> holding one keeps the session awake
    Process {
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=quickshell", "--why=caffeine", "sleep", "infinity"]
        running: root.caffeinated
    }

    // one-shot toast on every toggle -> picked up by the quickshell notification server
    Process {
        id: caffeineNotify
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
