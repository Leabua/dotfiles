pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

// niriBar's design tokens and shared state. The look is Material 3 Expressive: colour roles come from matugen
// (generated off the wallpaper), type is Roboto Flex on the M3 scale, corners follow the M3 shape scale and
// motion uses a strong ease-out for anything entering plus a light overshoot for things changing shape.
Singleton {
    id: root

    // ======================================================================================================
    // niri
    // ======================================================================================================
    property var niriWorkspaces: []
    property string niriFocusedOutput: ""

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: data => {
                let event;
                try {
                    event = JSON.parse(data);
                } catch (e) {
                    return;
                }
                if (event.WorkspacesChanged) {
                    root.niriWorkspaces = event.WorkspacesChanged.workspaces;
                    root.niriFocusedOutput = root.niriWorkspaces.find(w => w.is_focused)?.output ?? "";
                } else if (event.WorkspaceActivated?.focused) {
                    root.niriFocusedOutput = root.niriWorkspaces.find(w => w.id === event.WorkspaceActivated.id)?.output ?? "";
                }
            }
        }
    }

    // keyboard-opened menus and toasts follow the focused output
    readonly property var focusedScreen: {
        for (const s of Quickshell.screens)
            if (s.name === niriFocusedOutput)
                return s;
        return Quickshell.screens[0] ?? null;
    }

    // ======================================================================================================
    // colour -> M3 roles from matugen (~/.config/matugen/templates/niriBarTemplate.json)
    // ======================================================================================================
    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/niribar-colors.json"
        watchChanges: true
        onFileChanged: reload()

        // keys are matugen's own snake_case role names (an "onError" key would read as a signal handler).
        // sane defaults (a neutral green scheme) for a fresh install before matugen has run
        JsonAdapter {
            id: m3
            property string primary: "#acefc3"
            property string on_primary: "#002010"
            property string primary_container: "#68a880"
            property string on_primary_container: "#000000"
            property string secondary: "#cfe6d3"
            property string secondary_container: "#8aa08f"
            property string on_secondary_container: "#000000"
            property string tertiary: "#bce7f5"
            property string tertiary_container: "#78a1af"
            property string on_tertiary_container: "#000000"
            property string error: "#ffd7d2"
            property string on_error: "#3f0002"
            property string error_container: "#ff6b5e"
            property string on_error_container: "#000000"
            property string surface: "#0f1511"
            property string on_surface: "#ffffff"
            property string on_surface_variant: "#e5eee5"
            property string surface_container_lowest: "#030704"
            property string surface_container_low: "#1a1f1b"
            property string surface_container: "#252b26"
            property string surface_container_high: "#303631"
            property string surface_container_highest: "#3b413c"
            property string inverse_surface: "#dfe4dd"
            property string inverse_on_surface: "#191e1a"
            property string outline: "#b8c1b8"
            property string outline_variant: "#949d95"
        }
    }

    // M3's "on X" roles are named "X content" here: QML reads any name starting "on" + capital as a signal
    // handler, so onSurface & co. would never resolve as properties
    readonly property color primary: m3.primary
    readonly property color primaryContent: m3.on_primary
    readonly property color primaryContainer: m3.primary_container
    readonly property color primaryContainerContent: m3.on_primary_container
    readonly property color secondary: m3.secondary
    readonly property color secondaryContainer: m3.secondary_container
    readonly property color secondaryContainerContent: m3.on_secondary_container
    readonly property color tertiary: m3.tertiary
    readonly property color tertiaryContainer: m3.tertiary_container
    readonly property color tertiaryContainerContent: m3.on_tertiary_container
    readonly property color error: m3.error
    readonly property color errorContent: m3.on_error
    readonly property color errorContainer: m3.error_container
    readonly property color errorContainerContent: m3.on_error_container
    readonly property color surface: m3.surface
    readonly property color surfaceContent: m3.on_surface
    readonly property color surfaceVariantContent: m3.on_surface_variant
    readonly property color surfaceContainerLowest: m3.surface_container_lowest
    readonly property color surfaceContainerLow: m3.surface_container_low
    readonly property color surfaceContainer: m3.surface_container
    readonly property color surfaceContainerHigh: m3.surface_container_high
    readonly property color surfaceContainerHighest: m3.surface_container_highest
    readonly property color inverseSurface: m3.inverse_surface
    readonly property color inverseSurfaceContent: m3.inverse_on_surface
    readonly property color outline: m3.outline
    readonly property color outlineVariant: m3.outline_variant

    // M3 state layers: the content colour laid over a surface at a fixed opacity per interaction
    readonly property real stateHover: 0.08
    readonly property real stateFocus: 0.10
    readonly property real statePressed: 0.10
    readonly property real stateDragged: 0.16

    function stateLayer(base: color, content: color, opacity: real): color {
        return Qt.tint(base, Qt.alpha(content, opacity));
    }

    // ~~~ the names the menus were written against, mapped onto roles ~~~
    // fgColor is content (neutral on-surface, alpha-tiered by the menus); accents are placed explicitly
    readonly property color fgColor: surfaceContent
    readonly property color fgColor2: tertiary // second monitor's workspace pills
    readonly property color bgColor: surfaceContainer
    readonly property color menuBg: surfaceContainer
    readonly property color healthy: primary // charging past batteryFull, keep-awake on
    readonly property color warningColor: "#f6c86e" // M3 has no warning role; a warm amber that holds on any scheme
    readonly property color criticalColor: error

    // ======================================================================================================
    // type -> Roboto Flex on the M3 type scale
    // ======================================================================================================
    readonly property string fontFamily: "Roboto Flex"

    readonly property font textFont: Qt.font({
        family: fontFamily,
        pixelSize: 16,
        weight: Font.Medium
    })

    function type(size: int, weight: int): font {
        return Qt.font({
            family: fontFamily,
            pixelSize: size,
            weight: weight,
            features: {
                "tnum": 1
            }
        });
    }

    readonly property font displaySmall: type(36, Font.Normal)
    readonly property font headlineSmall: type(24, Font.Normal)
    readonly property font titleLarge: type(22, Font.Normal)
    readonly property font titleMedium: type(16, Font.Medium)
    readonly property font titleSmall: type(14, Font.Medium)
    readonly property font bodyLarge: type(16, Font.Normal)
    readonly property font bodyMedium: type(14, Font.Normal)
    readonly property font bodySmall: type(12, Font.Normal)
    readonly property font labelLarge: type(14, Font.Medium)
    readonly property font labelMedium: type(12, Font.Medium)
    readonly property font labelSmall: type(11, Font.Medium)

    // the clock's face: Roboto Flex condensed and semibold, with its tallest figures -> tall, solid stacked digits
    // that keep their counters open
    readonly property font clockFont: Qt.font({
        family: fontFamily,
        pixelSize: 26,
        weight: Font.DemiBold,
        variableAxes: {
            "wdth": 40,
            "wght": 580,
            "opsz": 144,
            "YTFI": 788
        },
        features: {
            "tnum": 1
        }
    })

    // ======================================================================================================
    // shape -> M3 Expressive corner scale
    // ======================================================================================================
    readonly property int shapeExtraSmall: 4
    readonly property int shapeSmall: 8
    readonly property int shapeMedium: 12
    readonly property int shapeLarge: 16
    readonly property int shapeLargeIncreased: 20
    readonly property int shapeExtraLarge: 28
    readonly property int shapeExtraLargeIncreased: 32
    readonly property int radius: shapeExtraLarge // menu cards

    // ======================================================================================================
    // the rail (bar)
    // ======================================================================================================
    // a floating M3 navigation rail on the left edge: items are 40px state-layer pills, an open menu's
    // trigger carries a secondary-container indicator, the ends are fully round
    readonly property int railWidth: 44
    readonly property int railItemWidth: 34
    readonly property int railItemHeight: 34
    readonly property int railPadding: 5 // rail edge -> item; the full-round ends get it top and bottom too
    readonly property int railGap: 4 // between rail items
    readonly property int railEdgeMargin: 6 // screen edge -> rail
    readonly property int railIconSize: 20
    readonly property real railIconStroke: 1.6
    readonly property int workspaceDot: 9

    // ~~~ names the shared bar pieces still read ~~~
    readonly property int barIconSize: railIconSize
    readonly property real barIconStroke: railIconStroke
    readonly property real barIconAlpha: 1
    readonly property font barFont: labelMedium
    readonly property int barThickness: railWidth
    readonly property int barEdgeMargin: railEdgeMargin

    // ======================================================================================================
    // spacing & layout
    // ======================================================================================================
    readonly property int spacing: 8
    readonly property int margins: 12 // card padding + clearance for menus
    readonly property int marginsTop: 6
    readonly property int marginsLeft: 8
    readonly property int marginsRight: 6
    readonly property int marginsBottom: -2
    readonly property int hyprGaps: 6 // menu card -> rail, matching the rail's own edge margin
    readonly property int borderWidth: 0
    readonly property color borderColor: outlineVariant

    // ======================================================================================================
    // motion
    // ======================================================================================================
    // enter: strong ease-out, quick to respond and soft to land. exit: shorter, the system is answering.
    // shape changes (indicators, toggles) get a light overshoot, M3 Expressive's "spatial" feel.
    readonly property int animFast: 90
    readonly property int animDuration: 160
    readonly property int animPress: 110
    readonly property int animEnter: 220
    readonly property int animExit: 130
    readonly property var easeOut: [0.23, 1, 0.32, 1, 1, 1]
    readonly property var easeSpatial: [0.34, 1.32, 0.64, 1, 1, 1]

    // ======================================================================================================
    // menu open-state
    // ======================================================================================================
    // rail clicks and the matching IPC handlers toggle these; the menus mounted from menus/ show / hide on them
    property bool wifiMenuOpen: false
    property bool audioMenuOpen: false
    property string audioMenuView: "audio" // "audio" | "bluetooth" -> which card the audio menu shows
    property bool engineRoomOpen: false
    property bool powerProfilesOpen: false
    property bool powerMenuOpen: false
    property bool systemMenuOpen: false
    property bool remindersOpen: false
    property var activePopup: null
    property var barWindows: []
    property bool popupClickThrough: false

    function dismissPopup(): void {
        if (activePopup)
            activePopup.dismissed();
    }

    // ---------- menu positioning ----------
    readonly property bool barVertical: true // menus open beside the rail rather than under a top bar
    readonly property int currentBarHeight: 0 // nothing across the top -> menus sit at the top edge
    property bool barShown: true
    readonly property int cardY: 24
    readonly property bool headerIcons: true
    readonly property bool buttonIcons: true

    // scene x of the rail item that opened the current menu -> the card opens beside the rail (-1 = not anchored)
    property real menuAnchorX: -1

    // screen rect of the open menu card -> toasts duck below a menu sitting in their spot (zero-width = nothing open)
    property rect menuCardRect: Qt.rect(0, 0, 0, 0)

    // wifi + system items on the rail (super + alt + space folds them away)
    property bool rightIslandShown: true

    // ======================================================================================================
    // live readings -> polled once here for the rail alerts, the system menu and the battery toasts
    // ======================================================================================================
    property int cpuUsage: 0
    property int memUsage: 0
    property real lastCpuIdle: 0
    property real lastCpuTotal: 0

    // read /proc directly via FileView -> no subprocess per tick
    FileView {
        id: cpuFile
        path: "/proc/stat"
        blockLoading: true
        onLoaded: {
            const p = text().split("\n")[0].trim().split(/\s+/); // aggregate "cpu ..." line
            const idle = parseInt(p[4]) + parseInt(p[5]);
            const total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
            if (root.lastCpuTotal)
                root.cpuUsage = Math.round(100 - (idle - root.lastCpuIdle) / (total - root.lastCpuTotal) * 100);
            root.lastCpuIdle = idle;
            root.lastCpuTotal = total;
        }
        Component.onCompleted: reload()
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        blockLoading: true
        onLoaded: {
            const t = text();
            const total = t.match(/MemTotal:\s+(\d+)/);
            const available = t.match(/MemAvailable:\s+(\d+)/);
            if (total && available)
                root.memUsage = Math.round((parseInt(total[1]) - parseInt(available[1])) / parseInt(total[1]) * 100);
        }
        Component.onCompleted: reload()
    }

    readonly property var battery: UPower.displayDevice
    readonly property bool batteryReady: battery != null && battery.ready
    readonly property int batteryPercent: batteryReady ? Math.round(battery.percentage * 100) : 0
    // UPower drops out of "Charging" once full (FullyCharged) or trickle-charging (PendingCharge) -> still plugged in
    readonly property bool batteryCharging: batteryReady && (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged || battery.state === UPowerDeviceState.PendingCharge)

    // ----- status thresholds: the rail alerts and the system menu read the same numbers -----
    readonly property int loadWarning: 70
    readonly property int loadCritical: 85
    readonly property int batteryLow: 20
    readonly property int batteryCritical: 10
    readonly property int batteryFull: 80 // charging past this reads as healthy

    function loadTint(percent: int): color {
        if (percent > loadCritical)
            return criticalColor;
        if (percent > loadWarning)
            return warningColor;
        return primary;
    }

    function batteryTint(percent: int, charging: bool): color {
        if (charging)
            return percent >= batteryFull ? healthy : primary;
        if (percent <= batteryCritical)
            return criticalColor;
        if (percent <= batteryLow)
            return warningColor;
        return primary;
    }

    // ----- one rail menu open at a time; clicking another rail item switches -----
    readonly property var barMenus: ({
            wifi: "wifiMenuOpen",
            audio: "audioMenuOpen",
            engineRoom: "engineRoomOpen",
            powerProfiles: "powerProfilesOpen",
            powerMenu: "powerMenuOpen",
            system: "systemMenuOpen"
        })

    function toggleMenu(name: string): void {
        const wasOpen = root[barMenus[name]];
        for (const key in barMenus)
            root[barMenus[key]] = false;
        if (!wasOpen)
            root[barMenus[name]] = true;
    }

    // ---------- keep awake ----------
    // off by default; re-enabled manually each session (not persisted across restarts)
    property bool caffeinated: false

    function toggleCaffeine(): void {
        caffeinated = !caffeinated;
        caffeineNotify.command = ["notify-send", "-a", "Keep awake", caffeinated ? "Keep awake on" : "Keep awake off", caffeinated ? "The session will stay awake" : "The session can sleep again"];
        caffeineNotify.running = true;
    }

    // hypridle honours logind idle / sleep inhibitors -> holding one keeps the session awake
    Process {
        command: ["systemd-inhibit", "--what=idle:sleep", "--who=quickshell", "--why=keep awake", "sleep", "infinity"]
        running: root.caffeinated
    }

    Process {
        id: caffeineNotify
    }

    // shared 5s tick
    property int tick: 0

    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            root.tick++;
            cpuFile.reload();
            memFile.reload();
        }
    }
}
