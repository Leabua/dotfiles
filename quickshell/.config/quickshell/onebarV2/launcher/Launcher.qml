pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.defaults
import qs.launcher
import "data/Score.js" as Score

import QtQuick
import QtQuick.Layouts

// Omni-style command palette / app launcher, ported from bjarneo/quickshell's
// OmniMenu into our patterns: PopupWindow chrome, Globals tokens, an IpcHandler
// toggle, and the manual-query keyboard model (PopupWindow forwards keys via
// keyDown -> we build `query` from event.text, no Qt TextField).
//
// Toggle from a WM keybind with:  qs ipc call launcher toggle
Scope {
    id: root

    property bool open: false
    property string query: ""
    property int selectedIndex: 0
    property var results: []

    // cached, pre-lowercased index of installed apps (rebuilt when the set changes)
    property var appIndex: []

    readonly property int cardWidth: 480
    readonly property int listHeight: 380

    // ----- indexing + filtering -----

    // build the scoring index once per app-set change; iconPath/lowercasing are
    // done here so per-keystroke filtering only has to score
    function indexApps(): void {
        const apps = DesktopEntries.applications.values;
        let out = [];
        for (const e of apps) {
            if (e.noDisplay)
                continue;
            const cats = e.categories || [];
            const kws = e.keywords || [];
            out.push({
                kind: "app",
                entry: e,
                title: e.name,
                category: cats.length ? cats[0] : "App",
                glyph: "󰣆",
                iconUrl: Quickshell.iconPath(e.icon, ""),
                _t: (e.name || "").toLowerCase(),
                _k: (kws.join(" ") + " " + (e.genericName || "") + " " + (e.comment || "")).toLowerCase(),
                _c: cats.join(" ").toLowerCase()
            });
        }
        root.appIndex = out;
        root.rebuild();
    }

    // score the cached index against the current query; empty query lists every
    // app alphabetically, and any typed text gets a trailing "run command" entry
    function rebuild(): void {
        const q = root.query.trim().toLowerCase();
        const tokens = q.length ? q.split(/\s+/) : [];
        let scored = [];
        for (const it of root.appIndex) {
            const score = tokens.length ? Score.scoreItem(it, tokens) : 1;
            if (score === 0)
                continue;
            scored.push({
                item: it,
                score: score
            });
        }
        scored.sort(Score.compare);
        let out = scored.map(s => s.item);
        if (root.query.trim().length > 0) {
            out.push({
                kind: "run",
                title: "Run  " + root.query.trim(),
                category: "COMMAND",
                glyph: "󰆍",
                iconUrl: "",
                command: root.query.trim()
            });
        }
        root.results = out;
        root.selectedIndex = 0;
    }

    // ----- selection + activation -----

    function moveSel(delta: int): void {
        const n = root.results.length;
        if (n === 0)
            return;
        root.selectedIndex = (root.selectedIndex + delta + n) % n;
    }

    function activate(item): void {
        if (!item)
            return;
        if (item.kind === "run")
            Quickshell.execDetached(["sh", "-c", item.command]);
        else if (item.entry)
            item.entry.execute();
        root.open = false;
    }

    function activateAt(index: int): void {
        root.activate(root.results[index]);
    }

    // ----- keyboard: build query + navigate (PopupWindow forwards via keyDown) -----
    function handleKey(event): void {
        const k = event.key;

        if (k === Qt.Key_Escape) {
            // first Escape clears a non-empty query; an empty query is left
            // unaccepted so PopupWindow closes the palette
            if (root.query.length > 0) {
                root.query = "";
                event.accepted = true;
            }
            return;
        }
        if (k === Qt.Key_Down || (k === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.moveSel(1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Up || k === Qt.Key_Backtab || (k === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.moveSel(-1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            root.activateAt(root.selectedIndex);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Backspace) {
            root.query = root.query.slice(0, -1);
            event.accepted = true;
            return;
        }
        // printable characters extend the query
        if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 0x20) {
            root.query += event.text;
            event.accepted = true;
        }
    }

    onQueryChanged: rebuild()

    onOpenChanged: {
        if (open) {
            query = "";
            selectedIndex = 0;
            indexApps();
        }
    }

    // refresh the index if apps are (un)installed while the palette is open
    Connections {
        target: DesktopEntries
        function onApplicationsChanged(): void {
            if (root.open)
                root.indexApps();
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            root.open = !root.open;
        }
        function show(): void {
            root.open = true;
        }
        function hide(): void {
            root.open = false;
        }
    }

    PopupWindow {
        open: root.open
        onDismissed: root.open = false
        hAlign: "center"
        // sit just below the bar when it's shown, shift up to the top when it's hidden
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: Globals.spacing
        onKeyDown: event => root.handleKey(event)

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            left: Globals.marginsLeft
            right: Globals.marginsRight
        }

        ColumnLayout {
            width: root.cardWidth
            spacing: Globals.spacing

            // heading
            RowLayout {
                Layout.fillWidth: true
                spacing: Globals.spacing

                Text {
                    text: "󰀻" // nf-md-apps
                    visible: Globals.headerIcons
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }

                Text {
                    Layout.fillWidth: true
                    text: "App Menu"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }
            }

            MenuDivider {}

            SearchInput {
                Layout.fillWidth: true
                query: root.query
                active: root.open
            }

            MenuDivider {}

            ResultList {
                Layout.fillWidth: true
                Layout.preferredHeight: root.listHeight
                results: root.results
                selectedIndex: root.selectedIndex
                onHovered: index => root.selectedIndex = index
                onActivated: index => root.activateAt(index)
            }
        }
    }
}
