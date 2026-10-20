pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates
import qs.menus.clipboard

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Clipboard history panel.
// Data comes from `cliphist` (wl-paste --watch cliphist store is already running).
//   cliphist list           -> "<id>\t<preview>" per line ([[ binary data ... ]] for images)
//   cliphist decode <id>    -> full text (stdout) or raw image bytes
//   cliphist wipe           -> clear all
// Window chrome and input handling come from PopupWindow.

Scope {
    id: root

    // local open state, toggled via IPC (mirrors Notifications' centerOpen)
    property bool clipboardOpen: false

    // drives both the highlight and the preview pane
    property int selectedIndex: 0

    // "all" | "text" | "image" — segmented filter above the list
    property string filterMode: "all"
    property string searchQuery: ""

    // ----- sizing -----
    readonly property int cardWidth: Math.min(792, popup.availableWidth)
    readonly property int listWidth: Math.floor((cardWidth - 16) * 0.4)
    readonly property int bodyHeight: Math.min(376, Math.max(120, popup.availableHeight - 210))
    readonly property int imageCount: {
        let count = 0;
        for (let i = 0; i < clipModel.count; i++)
            if (clipModel.get(i).isImage)
                count++;
        return count;
    }
    readonly property var selectedEntry: selectedIndex >= 0 && selectedIndex < filteredModel.count ? filteredModel.get(selectedIndex) : null
    property string errorText: ""

    // ----- preview state -----
    property string hoveredId: ""
    property bool previewIsImage: false
    property string previewText: ""
    property string previewImage: ""
    property string pendingImgPath: ""
    property bool previewLoading: false

    function imageDimensions(label: string): string {
        const match = label.match(/(\d+)x(\d+)/);
        return match ? match[1] + " × " + match[2] : "";
    }

    function imageDetail(label: string): string {
        const format = label.match(/\b(png|jpe?g|gif|webp|bmp|tiff?|avif)\b/i);
        const size = label.match(/\b\d+(?:\.\d+)?\s*[KMGT]?i?B\b/i);
        return (format ? format[1].toUpperCase() : "Image") + (size ? ", " + size[0] : "");
    }

    function textKind(text: string): string {
        return /^https?:\/\/\S+$/i.test(text.trim()) ? "Link" : "Text";
    }

    function entryTitle(label: string, isImage: bool): string {
        return isImage ? (root.imageDimensions(label) || "Image") : label.replace(/\s+/g, " ").trim();
    }

    function imgPathFor(id: string): string {
        return Quickshell.env("XDG_RUNTIME_DIR") + "/qs-clip-preview-" + id + ".img";
    }

    function refresh(): void {
        listProc.running = true;
    }

    // load the full content of an entry into the preview pane on hover
    function loadPreview(id: string, isImage: bool): void {
        root.hoveredId = id;
        root.previewIsImage = isImage;
        root.previewText = "";
        root.previewImage = "";
        root.previewLoading = true;
        root.startPreview();
    }

    // Serialize decodes so a fast hover cannot publish an older entry's content.
    function startPreview(): void {
        if (!/^\d+$/.test(root.hoveredId) || textDecodeProc.running || imgDecodeProc.running)
            return;
        const id = root.hoveredId;
        if (root.previewIsImage) {
            root.pendingImgPath = root.imgPathFor(id);
            imgDecodeProc.requestId = id;
            imgDecodeProc.command = ["sh", "-c", "umask 077; cliphist decode \"$1\" > \"$2\"", "preview", id, root.pendingImgPath];
            imgDecodeProc.running = true;
        } else {
            textDecodeProc.requestId = id;
            textDecodeProc.command = ["cliphist", "decode", id];
            textDecodeProc.running = true;
        }
    }

    function copyEntry(id: string): void {
        if (copyProc.running || !/^\d+$/.test(id))
            return;
        root.errorText = "";
        copyProc.command = ["bash", "-o", "pipefail", "-c", "cliphist decode \"$1\" | wl-copy", "copy", id];
        copyProc.running = true;
    }

    // ----- filtering (clipModel holds everything, filteredModel drives the list) -----
    function matchesFilter(isImage: bool): bool {
        if (root.filterMode === "text")
            return !isImage;
        if (root.filterMode === "image")
            return isImage;
        return true;
    }

    function applyFilter(): void {
        const tokens = root.searchQuery.trim().toLowerCase().split(/\s+/).filter(token => token.length > 0);
        filteredModel.clear();
        for (let i = 0; i < clipModel.count; i++) {
            const it = clipModel.get(i);
            const searchable = it.preview.toLowerCase();
            if (root.matchesFilter(it.isImage) && tokens.every(token => searchable.includes(token)))
                filteredModel.append({
                    cid: it.cid,
                    preview: it.preview,
                    isImage: it.isImage
                });
        }
        root.selectedIndex = 0;
        if (filteredModel.count > 0)
            root.select(0);
        else
            root.clearPreview();
        listView.positionViewAtBeginning();
    }

    function setFilter(mode: string): void {
        if (root.filterMode === mode)
            return;
        root.filterMode = mode;
        root.applyFilter();
    }

    function cycleFilter(): void {
        if (root.filterMode === "all")
            root.setFilter("text");
        else if (root.filterMode === "text")
            root.setFilter("image");
        else
            root.setFilter("all");
    }

    function filterEmptyText(): string {
        if (root.searchQuery.trim() !== "")
            return "No matching items";
        if (root.filterMode === "image")
            return "No images yet";
        if (root.filterMode === "text")
            return "No text yet";
        return "Your clipboard is empty";
    }

    // ----- selection (single source of truth, mirrors the launcher) -----

    // set the active row + load its preview; the hoveredId guard dedupes the
    // stream of hover events so we only re-decode when the row actually changes
    function select(index: int): void {
        if (index < 0 || index >= filteredModel.count)
            return;
        root.selectedIndex = index;
        const it = filteredModel.get(index);
        if (it.cid !== root.hoveredId)
            root.loadPreview(it.cid, it.isImage);
    }

    function moveSel(delta: int): void {
        const n = filteredModel.count;
        if (n === 0)
            return;
        root.select((root.selectedIndex + delta + n) % n);
    }

    function activateAt(index: int): void {
        if (index < 0 || index >= filteredModel.count)
            return;
        root.copyEntry(filteredModel.get(index).cid);
    }

    // PopupWindow forwards every keypress here; an unaccepted Escape (and an
    // outside click) is left to PopupWindow, which closes the panel
    function handleKey(event): void {
        const k = event.key;
        const control = !!(event.modifiers & Qt.ControlModifier);
        if (k === Qt.Key_Escape && root.searchQuery !== "") {
            root.searchQuery = "";
            event.accepted = true;
            return;
        }
        if (control && (k === Qt.Key_F || k === Qt.Key_L)) {
            searchField.forceActiveFocus();
            searchField.selectAll();
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Down || (k === Qt.Key_Tab && !control && !(event.modifiers & Qt.ShiftModifier))) {
            root.moveSel(1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Up || (k === Qt.Key_Backtab && !control) || (k === Qt.Key_Tab && !control && (event.modifiers & Qt.ShiftModifier))) {
            root.moveSel(-1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            root.activateAt(root.selectedIndex);
            event.accepted = true;
            return;
        }
        // Leave unmodified letters and numbers available for searching.
        if (control && k === Qt.Key_Tab) {
            root.cycleFilter();
            event.accepted = true;
            return;
        }
        if (control && k === Qt.Key_1) {
            root.setFilter("all");
            event.accepted = true;
            return;
        }
        if (control && k === Qt.Key_2) {
            root.setFilter("text");
            event.accepted = true;
            return;
        }
        if (control && k === Qt.Key_3) {
            root.setFilter("image");
            event.accepted = true;
            return;
        }
        if (!searchField.activeFocus && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            if (k === Qt.Key_Backspace) {
                root.searchQuery = root.searchQuery.slice(0, -1);
                event.accepted = true;
            } else if (event.text && event.text.length > 0 && event.text.charCodeAt(0) >= 0x20) {
                root.searchQuery += event.text;
                searchField.forceActiveFocus();
                searchField.cursorPosition = searchField.length;
                event.accepted = true;
            }
        }
    }

    function clearPreview(): void {
        root.hoveredId = "";
        root.previewText = "";
        root.previewImage = "";
        root.previewIsImage = false;
        root.previewLoading = false;
    }

    onSearchQueryChanged: applyFilter()

    // refresh list + reset preview/selection whenever the panel opens
    onClipboardOpenChanged: {
        if (clipboardOpen) {
            errorText = "";
            filterMode = "all";
            searchQuery = "";
            selectedIndex = 0;
            clearPreview();
            refresh();
        }
    }

    // ----- backend model -----
    ListModel {
        id: clipModel
    }

    // visible slice of clipModel after the type filter; the ListView binds here
    ListModel {
        id: filteredModel
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                clipModel.clear();
                const lines = text.split("\n");

                for (const line of lines) {
                    if (line.trim() === "")
                        continue;
                    const tab = line.indexOf("\t");
                    if (tab < 0)
                        continue;

                    const id = line.substring(0, tab);
                    const prev = line.substring(tab + 1);
                    const isImg = prev.startsWith("[[ binary data");
                    // turn "[[ binary data 2 MiB png 1920x2160 ]]" into a tidy label
                    const label = isImg ? "Image · " + prev.replace("[[ binary data ", "").replace(" ]]", "") : prev;
                    clipModel.append({
                        cid: id,
                        preview: label,
                        isImage: isImg
                    });
                }
                // select + preview the most recent entry by default
                root.applyFilter();
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0)
                root.errorText = "Could not read clipboard history";
        }
    }

    Process {
        id: textDecodeProc
        property string requestId: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (textDecodeProc.requestId === root.hoveredId && !root.previewIsImage) {
                    root.previewText = text;
                    root.previewLoading = false;
                }
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0 && textDecodeProc.requestId === root.hoveredId) {
                root.previewLoading = false;
                root.errorText = "Could not load this preview";
            }
            if (textDecodeProc.requestId !== root.hoveredId)
                Qt.callLater(root.startPreview);
        }
    }

    Process {
        id: imgDecodeProc
        property string requestId: ""
        onExited: (exitCode, exitStatus) => {
            if (imgDecodeProc.requestId === root.hoveredId && root.previewIsImage) {
                root.previewLoading = false;
                if (exitCode === 0)
                    root.previewImage = "file://" + root.pendingImgPath;
                else
                    root.errorText = "Could not load this preview";
            }
            if (imgDecodeProc.requestId !== root.hoveredId)
                Qt.callLater(root.startPreview);
        }
    }

    Process {
        id: copyProc
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim() !== "")
                    console.warn("Clipboard copy:", text.trim());
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.clipboardOpen = false;
            else
                root.errorText = "Could not copy this entry";
        }
    }

    Process {
        id: wipeProc
        command: ["cliphist", "wipe"]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.clearPreview();
                root.refresh();
            } else {
                root.errorText = "Could not clear clipboard history";
            }
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void {
            root.clipboardOpen = !root.clipboardOpen;
        }
        function show(): void {
            root.clipboardOpen = true;
        }
        function hide(): void {
            root.clipboardOpen = false;
        }
    }

    PopupWindow {
        id: popup
        open: root.clipboardOpen
        onDismissed: root.clipboardOpen = false
        onKeyDown: event => root.handleKey(event)
        padding: 16
        backgroundColor: Globals.bgColor

        Shortcut {
            sequence: "Return"
            context: Qt.WindowShortcut
            enabled: root.clipboardOpen
            autoRepeat: false
            onActivated: root.activateAt(root.selectedIndex)
        }

        Shortcut {
            sequence: "Enter"
            context: Qt.WindowShortcut
            enabled: root.clipboardOpen
            autoRepeat: false
            onActivated: root.activateAt(root.selectedIndex)
        }

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            left: Globals.marginsLeft
            right: Globals.marginsRight
        }

        ColumnLayout {
            width: root.cardWidth
            spacing: 12

            MenuHeader {
                title: "Clipboard"
                icon: "clipboard"
                actionText: "Clear history"
                actionIcon: "trash"
                actionDestructive: true
                actionEnabled: clipModel.count > 0 && !wipeProc.running
                onActionClicked: wipeProc.running = true
                onCloseRequested: root.clipboardOpen = false
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 9
                color: Qt.lighter(Globals.bgColor, 1.35)
                border.width: 1
                border.color: Qt.alpha(Globals.fgColor, searchField.activeFocus ? 0.22 : 0.03)

                MenuIcon {
                    x: 13
                    anchors.verticalCenter: parent.verticalCenter
                    name: "search"
                    color: Qt.alpha(Globals.fgColor, 0.45)
                }

                TextField {
                    id: searchField
                    anchors.left: parent.left
                    anchors.leftMargin: 42
                    anchors.right: clearSearch.left
                    anchors.rightMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    padding: 0
                    text: root.searchQuery
                    onTextEdited: root.searchQuery = text
                    placeholderText: "Search clipboard…"
                    placeholderTextColor: Qt.alpha(Globals.fgColor, 0.4)
                    color: Globals.fgColor
                    selectionColor: Qt.alpha(Globals.fgColor, 0.25)
                    selectedTextColor: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: 14
                    font.weight: Font.Normal
                    background: null
                    selectByMouse: true
                    Keys.onPressed: event => {
                        event.accepted = false;
                        root.handleKey(event);
                    }
                }

                Item {
                    id: clearSearch
                    width: 36
                    height: parent.height
                    anchors.right: parent.right

                    MenuIcon {
                        visible: root.searchQuery !== ""
                        anchors.centerIn: parent
                        name: "close"
                        color: Qt.alpha(Globals.fgColor, 0.6)
                        width: 16
                        height: 16
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.searchQuery !== ""
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.searchQuery = "";
                            searchField.forceActiveFocus();
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 2

                ClipboardFilter {
                    label: "All"
                    count: clipModel.count
                    active: root.filterMode === "all"
                    onClicked: root.setFilter("all")
                }
                ClipboardFilter {
                    label: "Text"
                    count: clipModel.count - root.imageCount
                    active: root.filterMode === "text"
                    onClicked: root.setFilter("text")
                }
                ClipboardFilter {
                    label: "Images"
                    count: root.imageCount
                    active: root.filterMode === "image"
                    onClicked: root.setFilter("image")
                }

                Item { Layout.fillWidth: true }

            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.bodyHeight

                RowLayout {
                    anchors.fill: parent
                    spacing: 16
                    visible: filteredModel.count > 0

                    ListView {
                        id: listView
                        Layout.preferredWidth: root.listWidth
                        Layout.fillHeight: true
                        model: filteredModel
                        currentIndex: root.selectedIndex
                        highlightFollowsCurrentItem: false
                        boundsBehavior: Flickable.StopAtBounds
                        clip: true
                        cacheBuffer: 200
                        pixelAligned: true
                        spacing: 4
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                            onWheel: event => {
                                const maxY = Math.max(0, listView.contentHeight - listView.height);
                                listView.contentY = Math.max(0, Math.min(maxY, listView.contentY - event.angleDelta.y * 2));
                            }
                        }

                        delegate: ClipboardEntry {
                            id: entry
                            required property string cid
                            required property string preview
                            required property bool isImage
                            required property int index

                            width: ListView.view.width
                            height: implicitHeight
                            title: root.entryTitle(entry.preview, entry.isImage)
                            detail: entry.isImage ? root.imageDetail(entry.preview) : root.textKind(entry.preview)
                            selected: root.selectedIndex === entry.index
                            onHovered: root.select(entry.index)
                            onClicked: root.activateAt(entry.index)
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: Qt.darker(Globals.bgColor, 1.2)
                        border.width: 1
                        border.color: Qt.alpha(Globals.fgColor, 0.045)

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 16
                            spacing: 14

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                MenuIcon {
                                    name: root.previewIsImage ? "image" : "text"
                                    color: Qt.alpha(Globals.fgColor, 0.5)
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: root.previewIsImage ? "Image" : root.selectedEntry ? root.textKind(root.selectedEntry.preview) : "Text"
                                    color: Qt.alpha(Globals.fgColor, 0.65)
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 12
                                    font.weight: Font.Medium
                                }

                                Text {
                                    text: root.previewIsImage && root.selectedEntry ? root.imageDimensions(root.selectedEntry.preview) : root.previewLoading ? "" : root.previewText.length.toLocaleString() + " characters"
                                    color: Qt.alpha(Globals.fgColor, 0.4)
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 11
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                Image {
                                    id: imagePreview
                                    anchors.centerIn: parent
                                    width: Math.min(parent.width, implicitWidth)
                                    height: Math.min(parent.height, implicitHeight)
                                    visible: root.previewIsImage && root.previewImage !== ""
                                    source: root.previewImage
                                    fillMode: Image.PreserveAspectFit
                                    asynchronous: true
                                    cache: false
                                }

                                Flickable {
                                    id: previewScroll
                                    anchors.fill: parent
                                    visible: !root.previewIsImage && root.hoveredId !== "" && !root.previewLoading
                                    clip: true
                                    contentWidth: width
                                    contentHeight: preview.contentHeight
                                    boundsBehavior: Flickable.StopAtBounds
                                    onVisibleChanged: contentY = 0
                                    ScrollBar.vertical: ScrollBar {
                                        policy: ScrollBar.AsNeeded
                                    }

                                    Connections {
                                        target: root
                                        function onHoveredIdChanged(): void {
                                            previewScroll.contentY = 0;
                                        }
                                    }

                                    TextEdit {
                                        id: preview
                                        width: previewScroll.width
                                        text: root.previewText
                                        readOnly: true
                                        selectByMouse: true
                                        textFormat: TextEdit.PlainText
                                        color: Qt.alpha(Globals.fgColor, 0.88)
                                        selectionColor: Qt.alpha(Globals.fgColor, 0.25)
                                        selectedTextColor: Globals.fgColor
                                        font.family: Globals.textFont.family
                                        font.pixelSize: 14
                                        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                                        Keys.onPressed: event => {
                                            event.accepted = false;
                                            root.handleKey(event);
                                            if (!event.accepted && event.key === Qt.Key_Escape)
                                                root.clipboardOpen = false;
                                        }
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    visible: root.previewLoading || (root.previewIsImage && imagePreview.status === Image.Loading)
                                    text: "Loading preview…"
                                    color: Qt.alpha(Globals.fgColor, 0.4)
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 13
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    width: Math.min(300, parent.width)
                    visible: filteredModel.count === 0
                    spacing: 12

                    MenuIcon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        name: root.searchQuery.trim() !== "" ? "search" : "clipboard"
                        color: Qt.alpha(Globals.fgColor, 0.3)
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.filterEmptyText()
                        color: Qt.alpha(Globals.fgColor, 0.8)
                        horizontalAlignment: Text.AlignHCenter
                        font.family: Globals.textFont.family
                        font.pixelSize: 15
                        font.weight: Font.Medium
                    }

                    Text {
                        Layout.fillWidth: true
                        text: root.searchQuery.trim() !== "" ? "Try a different search or filter." : "Copy " + (root.filterMode === "image" ? "an image" : root.filterMode === "text" ? "some text" : "text or an image") + " to see it here."
                        color: Qt.alpha(Globals.fgColor, 0.4)
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        font.family: Globals.textFont.family
                        font.pixelSize: 13
                    }
                }
            }

            Text {
                visible: root.errorText !== ""
                Layout.fillWidth: true
                text: root.errorText
                color: Globals.criticalColor
                font.family: Globals.textFont.family
                font.pixelSize: 13
                wrapMode: Text.WordWrap
            }
        }
    }
}
