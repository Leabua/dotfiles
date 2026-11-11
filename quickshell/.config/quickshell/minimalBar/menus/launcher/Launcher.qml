pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates
import qs.menus.launcher
import "data/Score.js" as Score

import QtQuick
import QtQuick.Layouts

// Omni-style app launcher, ported from bjarneo/quickshelldots <- github

Scope {
    id: root
    property bool open: false
    property string query: ""
    property int selectedIndex: 0
    property var results: []

    // cached, pre-lowercased index of installed apps (rebuilt when the set changes)
    property var appIndex: []

    // launch history shared by both bars: { apps: {id: {count, last}}, queries: {q: {id: hits}} }
    readonly property string usageDir: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/quickshell"
    readonly property string usagePath: usageDir + "/launcher-usage.json"
    property var usage: ({
            apps: {},
            queries: {}
        })

    readonly property int cardWidth: Math.min(480, popup.availableWidth)
    readonly property int listHeight: Math.min(380, Math.max(120, popup.availableHeight - 120))

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
            const t = (e.name || "").toLowerCase();
            const words = t.split(/[\s\-_.:()]+/).filter(w => w.length);
            const kwText = (kws.join(" ") + " " + (e.genericName || "")).toLowerCase();
            out.push({
                kind: "app",
                entry: e,
                title: e.name,
                category: cats.length ? cats[0] : "App",
                glyph: "󰣆",
                iconUrl: Quickshell.iconPath(e.icon, ""),
                id: e.id || e.name,
                _t: t,
                _w: words,
                _a: words.map(w => w[0]).join(""),
                _k: (kwText + " " + (e.comment || "")).toLowerCase(),
                _kw: kwText.split(/[\s;,\-]+/).filter(w => w.length),
                _c: cats.join(" ").toLowerCase()
            });
        }
        root.appIndex = out;
        root.rebuild();
    }

    // score the cached index against the current query; an empty query lists
    // every app, most used first

    function rebuild(): void {
        const q = root.query.trim().toLowerCase();
        const tokens = q.length ? q.split(/\s+/) : [];
        const now = Date.now();
        let scored = [];
        for (const it of root.appIndex) {
            const score = Score.scoreItem(it, q, tokens, root.usage, now);
            if (score === 0)
                continue;
            scored.push({
                item: it,
                score: score
            });
        }
        scored.sort(tokens.length ? Score.compare : Score.compareBrowse);
        root.results = scored.map(s => s.item);
        root.selectedIndex = 0;
    }

    // ----- selection + activation -----

    // single steps wrap around both ends; page jumps clamp, then wrap once
    // you're already sitting on the edge
    function moveSel(delta: int): void {
        const n = root.results.length;
        if (n === 0)
            return;
        const cur = root.selectedIndex;
        if (Math.abs(delta) === 1) {
            root.selectedIndex = ((cur + delta) % n + n) % n;
            return;
        }
        if (delta > 0)
            root.selectedIndex = cur === n - 1 ? 0 : Math.min(n - 1, cur + delta);
        else
            root.selectedIndex = cur === 0 ? n - 1 : Math.max(0, cur + delta);
    }

    function activate(item): void {
        if (!item)
            return;
        if (item.entry)
            item.entry.execute();
        root.recordLaunch(item);
        root.open = false;
    }

    function activateAt(index: int): void {
        root.activate(root.results[index]);
    }

    // ----- usage persistence -----

    function recordLaunch(item): void {
        const q = root.query.trim().toLowerCase();
        root.usage = Score.record(root.usage, item.id, q, Date.now());
        usageFile.setText(JSON.stringify(root.usage));
    }

    function loadUsage(text: string): void {
        try {
            const u = JSON.parse(text);
            root.usage = {
                apps: u.apps || {},
                queries: u.queries || {}
            };
        } catch (e) {
            // missing / corrupt file -> start fresh
        }
    }

    Process {
        id: usageDirProc
        command: ["mkdir", "-p", root.usageDir]
        running: true
    }

    FileView {
        id: usageFile
        path: root.usagePath
        atomicWrites: true
        printErrors: false
        // the other bar (or a previous session) may have written newer history
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadUsage(text())
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
        const ctrl = event.modifiers & Qt.ControlModifier;
        if (k === Qt.Key_PageDown || k === Qt.Key_PageUp) {
            root.moveSel(k === Qt.Key_PageDown ? 8 : -8);
            event.accepted = true;
            return;
        }
        if (ctrl && (k === Qt.Key_Home || k === Qt.Key_End)) {
            root.selectedIndex = k === Qt.Key_Home ? 0 : Math.max(0, root.results.length - 1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Down || (ctrl && (k === Qt.Key_N || k === Qt.Key_J)) || (k === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.moveSel(1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Up || (ctrl && (k === Qt.Key_P || k === Qt.Key_K)) || k === Qt.Key_Backtab || (k === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
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
        if (!(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier)) && event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 0x20) {
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
        id: popup
        open: root.open
        onDismissed: root.open = false
        hAlign: "center"
        // sit just below the bar when it's shown, shift up to the top when it's hidden
        verticallyCentered: true
        padding: 12
        backgroundColor: Globals.bgColor
        onKeyDown: event => root.handleKey(event)

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            left: Globals.marginsLeft
            right: Globals.marginsRight
        }

        // no title bar: a palette opened all day leads with the thing you type into
        ColumnLayout {
            width: root.cardWidth
            spacing: 8

            SearchInput {
                Layout.fillWidth: true
                query: root.query
                active: root.open
            }

            ResultList {
                id: resultList
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
