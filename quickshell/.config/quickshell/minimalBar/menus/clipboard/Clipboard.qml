pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates

import QtQuick
import QtQuick.Layouts

// Clipboard history panel.
// Data comes from `cliphist` (wl-paste --watch cliphist store is already running).
//   cliphist list           -> "<id>\t<preview>" per line ([[ binary data ... ]] for images)
//   cliphist decode <id>    -> full text (stdout) or raw image bytes
//   cliphist wipe           -> clear all
// Styling mirrors the notification center; window chrome comes from PopupWindow.

Scope {
    id: root

    // local open state, toggled via IPC (mirrors Notifications' centerOpen)
    property bool clipboardOpen: false

    // drives both the highlight and the preview pane
    property int selectedIndex: 0

    // "all" | "text" | "image" — segmented filter above the list
    property string filterMode: "all"

    // ----- sizing -----
    readonly property int listWidth: Math.min(300, Math.floor((popup.availableWidth - 30) * 0.4))
    readonly property int previewWidth: Math.min(450, popup.availableWidth - listWidth - 30)
    readonly property int bodyHeight: Math.min(460, Math.max(120, popup.availableHeight - 140))
    property string errorText: ""

    // ----- preview state -----
    property string hoveredId: ""
    property bool previewIsImage: false
    property string previewText: ""
    property string previewImage: ""
    property string pendingImgPath: ""

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
        filteredModel.clear();
        for (let i = 0; i < clipModel.count; i++) {
            const it = clipModel.get(i);
            if (root.matchesFilter(it.isImage))
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
        if (root.filterMode === "image")
            return "No images in clipboard";
        if (root.filterMode === "text")
            return "No text in clipboard";
        return "No clipboard history";
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
        // F cycles All -> Text -> Images; 1/2/3 jump straight there
        if (k === Qt.Key_F) {
            root.cycleFilter();
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_1) {
            root.setFilter("all");
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_2) {
            root.setFilter("text");
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_3) {
            root.setFilter("image");
            event.accepted = true;
        }
    }

    function clearPreview(): void {
        root.hoveredId = "";
        root.previewText = "";
        root.previewImage = "";
        root.previewIsImage = false;
    }

    // refresh list + reset preview/selection whenever the panel opens
    onClipboardOpenChanged: {
        if (clipboardOpen) {
            errorText = "";
            filterMode = "all";
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
                if (textDecodeProc.requestId === root.hoveredId && !root.previewIsImage)
                    root.previewText = text;
            }
        }
        onExited: (exitCode, exitStatus) => {
            if (textDecodeProc.requestId !== root.hoveredId)
                Qt.callLater(root.startPreview);
        }
    }

    Process {
        id: imgDecodeProc
        property string requestId: ""
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && imgDecodeProc.requestId === root.hoveredId && root.previewIsImage)
                root.previewImage = "file://" + root.pendingImgPath;
            if (imgDecodeProc.requestId !== root.hoveredId)
                Qt.callLater(root.startPreview);
        }
    }

    Process {
        id: copyProc
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
        onExited: {
            root.clearPreview();
            root.refresh();
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

    // PopupWindow provides the full-screen catcher, keyboard focus + close-on-keypress
    PopupWindow {
        id: popup
        open: root.clipboardOpen
        onDismissed: root.clipboardOpen = false
        onKeyDown: event => root.handleKey(event)

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            left: Globals.marginsLeft
        }

        ColumnLayout {
            id: col
            spacing: Globals.spacing + 2

            // ---- header ----
            RowLayout {
                Layout.fillWidth: true
                // nudge the heading + clear button inward off the panel edges
                Layout.leftMargin: Globals.spacing
                Layout.rightMargin: Globals.spacing
                spacing: Globals.spacing

                Text {
                    text: String.fromCodePoint(0xF014D) // nf-md-clipboard_text 󰅍
                    visible: Globals.headerIcons
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 6
                    font.weight: Globals.textFont.weight
                }

                Text {
                    Layout.fillWidth: true
                    text: "Clipboard"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }

                Text {
                    text: "Clear all"
                    visible: clipModel.count > 0
                    color: Globals.criticalColor
                    font.family: Globals.textFont.family
                    font.weight: Globals.textFont.weight
                    font.pixelSize: Globals.textFont.pixelSize - 1

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wipeProc.running = true
                    }
                }
            }

            MenuDivider {
                Layout.leftMargin: Globals.spacing
                Layout.rightMargin: Globals.spacing
            }

            // ---- filter: All | Text | Images (F cycles, 1/2/3 jump) ----
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Globals.spacing
                Layout.rightMargin: Globals.spacing
                spacing: Globals.spacing

                ViewSwitchBtn {
                    label: "All"
                    isActive: root.filterMode === "all"
                    onClicked: root.setFilter("all")
                }
                ViewSwitchBtn {
                    label: "Text"
                    isActive: root.filterMode === "text"
                    onClicked: root.setFilter("text")
                }
                ViewSwitchBtn {
                    label: "Images"
                    isActive: root.filterMode === "image"
                    onClicked: root.setFilter("image")
                }
            }

            MenuDivider {
                Layout.leftMargin: Globals.spacing
                Layout.rightMargin: Globals.spacing
            }

            // empty state - keeps the list column's width (no preview pane) so the panel doesn't shrink horizontally when there's no history
            Text {
                visible: filteredModel.count === 0
                Layout.preferredWidth: root.listWidth
                text: root.filterEmptyText()
                color: Qt.alpha(Globals.fgColor, 0.4)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 1
                horizontalAlignment: Text.AlignHCenter
            }

            // ---- body: list (left) + preview (right) ----
            // only present when there is history; otherwise the second column doesn't exist
            RowLayout {
                visible: filteredModel.count > 0
                Layout.fillWidth: true
                spacing: Globals.spacing + 2

                // left: scrollable entry list (selection model mirrors the launcher's
                // ResultList - selectedIndex is the single source of truth)
                ListView {
                    id: listView
                    Layout.preferredWidth: root.listWidth
                    Layout.preferredHeight: root.bodyHeight
                    model: filteredModel
                    currentIndex: root.selectedIndex
                    highlightFollowsCurrentItem: false
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    cacheBuffer: 200
                    pixelAligned: true
                    spacing: Globals.spacing

                    // keep the keyboard-selected row scrolled into view
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    // bigger, smoother wheel step than the default (same as the launcher)
                    WheelHandler {
                        property real scrollSpeed: 2
                        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                        onWheel: event => {
                            const maxY = Math.max(0, listView.contentHeight - listView.height);
                            listView.contentY = Math.max(0, Math.min(maxY, listView.contentY - event.angleDelta.y * scrollSpeed));
                        }
                    }

                    delegate: Rectangle {
                        id: entry
                        required property string cid
                        required property string preview
                        required property bool isImage
                        required property int index

                        readonly property bool sel: root.selectedIndex === entry.index

                        width: ListView.view.width
                        implicitHeight: entryText.implicitHeight + (Globals.spacing + 2) * 2
                        radius: Globals.radius

                        // faint tint on the active entry (matches the launcher list)
                        color: entry.sel ? Qt.alpha(Globals.fgColor, 0.15) : "transparent"

                        Behavior on color {
                            ColorAnimation {
                                duration: Globals.animFast
                            }
                        }

                        Text {
                            id: entryText
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                leftMargin: Globals.spacing + 8
                                rightMargin: Globals.spacing + 2
                            }
                            text: entry.preview
                            textFormat: Text.PlainText
                            color: Globals.fgColor
                            font.family: Globals.textFont.family
                            font.pixelSize: Globals.textFont.pixelSize - 1
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        MouseArea {
                            id: ema
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onPositionChanged: root.select(entry.index)
                            onClicked: root.activateAt(entry.index)
                        }
                    }
                }

                // thin divider between list and preview (equal top/bottom gaps)
                Rectangle {
                    Layout.preferredWidth: Globals.borderWidth === 0 ? 1 : Globals.borderWidth // keeps the divider regardless of if we go no borders or not
                    Layout.preferredHeight: root.bodyHeight - Globals.padding * 2
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: Globals.spacing
                    color: Qt.alpha(Globals.fgColor, 0.3)
                }

                // right: fixed-width preview of the hovered entry
                Item {
                    Layout.preferredWidth: root.previewWidth
                    Layout.preferredHeight: root.bodyHeight
                    clip: true

                    // image preview
                    Image {
                        anchors.fill: parent
                        anchors.margins: Globals.spacing
                        visible: root.previewIsImage && root.previewImage !== ""
                        source: root.previewImage
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                        cache: false
                    }

                    // text preview - starts top-left and reads down like a book
                    Flickable {
                        id: previewScroll
                        anchors.fill: parent
                        anchors.margins: Globals.spacing
                        visible: !root.previewIsImage && root.hoveredId !== ""
                        clip: true
                        contentWidth: width
                        contentHeight: preview.contentHeight
                        boundsBehavior: Flickable.StopAtBounds
                        onVisibleChanged: contentY = 0
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
                            color: Globals.fgColor
                            selectionColor: Globals.fgColor
                            selectedTextColor: Globals.bgColor
                            font.family: Globals.textFont.family
                            font.pixelSize: Globals.textFont.pixelSize - 1
                            wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                            Keys.onPressed: event => {
                                event.accepted = false;
                                root.handleKey(event);
                                if (!event.accepted && event.key === Qt.Key_Escape)
                                    root.clipboardOpen = false;
                            }
                        }
                    }
                }
            }
            Text {
                visible: root.errorText !== ""
                Layout.fillWidth: true
                text: root.errorText
                color: Globals.criticalColor
                font: Globals.textFont
            }
        }
    }
}
