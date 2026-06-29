pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.defaults

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

    // ----- sizing -----
    readonly property int listWidth: 300                              // left list / truncation width
    readonly property int previewWidth: Math.round(listWidth * 1.5)   // right preview pane, 1.5x the list
    readonly property int bodyHeight: 460                             // fixed height for both columns

    // ----- preview state -----
    property string hoveredId: ""
    property bool previewIsImage: false
    property string previewText: ""
    property string previewImage: ""
    property string pendingImgPath: ""

    function imgPathFor(id: string): string {
        return "/tmp/qs-clip-preview-" + id + ".img";
    }

    function refresh(): void {
        listProc.running = true;
    }

    // load the full content of an entry into the preview pane on hover
    function loadPreview(id: string, isImage: bool): void {
        root.hoveredId = id;
        root.previewIsImage = isImage;
        if (isImage) {
            root.previewText = "";
            root.previewImage = "";
            root.pendingImgPath = root.imgPathFor(id);
            imgDecodeProc.running = false;
            imgDecodeProc.command = ["sh", "-c", "cliphist decode " + id + " > " + root.pendingImgPath];
            imgDecodeProc.running = true;
        } else {
            root.previewImage = "";
            textDecodeProc.running = false;
            textDecodeProc.command = ["cliphist", "decode", id];
            textDecodeProc.running = true;
        }
    }

    function copyEntry(id: string): void {
        copyProc.command = ["sh", "-c", "cliphist decode " + id + " | wl-copy"];
        copyProc.running = true;
    }

    // ----- selection (single source of truth, mirrors the launcher) -----

    // set the active row + load its preview; the hoveredId guard dedupes the
    // stream of hover events so we only re-decode when the row actually changes
    function select(index: int): void {
        if (index < 0 || index >= clipModel.count)
            return;
        root.selectedIndex = index;
        const it = clipModel.get(index);
        if (it.cid !== root.hoveredId)
            root.loadPreview(it.cid, it.isImage);
    }

    function moveSel(delta: int): void {
        const n = clipModel.count;
        if (n === 0)
            return;
        root.select((root.selectedIndex + delta + n) % n);
    }

    function activateAt(index: int): void {
        if (index < 0 || index >= clipModel.count)
            return;
        root.copyEntry(clipModel.get(index).cid);
        root.clipboardOpen = false;
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
            selectedIndex = 0;
            clearPreview();
            refresh();
        }
    }

    // ----- backend model -----
    ListModel {
        id: clipModel
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
                if (clipModel.count > 0)
                    root.select(0);
                else
                    root.clearPreview();
            }
        }
    }

    Process {
        id: textDecodeProc
        stdout: StdioCollector {
            onStreamFinished: root.previewText = text
        }
    }

    Process {
        id: imgDecodeProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0)
                root.previewImage = "file://" + root.pendingImgPath;
        }
    }

    Process {
        id: copyProc
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
        open: root.clipboardOpen
        onDismissed: root.clipboardOpen = false
        onKeyDown: event => root.handleKey(event)

        margins {
            top: Globals.marginsTop
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
                    text: String.fromCodePoint(0xF014C) // nf-md-clipboard
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

            // empty state - keeps the list column's width (no preview pane) so the panel doesn't shrink horizontally when there's no history
            Text {
                visible: clipModel.count === 0
                Layout.preferredWidth: root.listWidth
                text: "No clipboard history"
                color: Qt.alpha(Globals.fgColor, 0.4)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 1
                horizontalAlignment: Text.AlignHCenter
            }

            // ---- body: list (left) + preview (right) ----
            // only present when there is history; otherwise the second column doesn't exist
            RowLayout {
                visible: clipModel.count > 0
                Layout.fillWidth: true
                spacing: Globals.spacing + 2

                // left: scrollable entry list (selection model mirrors the launcher's
                // ResultList - selectedIndex is the single source of truth)
                ListView {
                    id: listView
                    Layout.preferredWidth: root.listWidth
                    Layout.preferredHeight: root.bodyHeight
                    model: clipModel
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

                        // short colour bar on the left edge of the active entry; fades
                        // with the same timing as the row tint so the two move together
                        Rectangle {
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.topMargin: Globals.spacing
                            anchors.bottomMargin: Globals.spacing
                            width: 3
                            radius: 2
                            color: Globals.fgColor
                            opacity: entry.sel ? 1 : 0
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Globals.animFast
                                }
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
                    Text {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: Globals.spacing
                        }
                        visible: !root.previewIsImage && root.hoveredId !== ""
                        text: root.previewText
                        color: Globals.fgColor
                        font.family: Globals.textFont.family
                        font.pixelSize: Globals.textFont.pixelSize - 1
                        horizontalAlignment: Text.AlignLeft
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }
                }
            }
        }
    }
}
