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

    // local open state, toggled via IPC (mirrors what I did in Notifications' centerOpen S/O tony on yt)
    property bool clipboardOpen: false

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

    function clearPreview(): void {
        root.hoveredId = "";
        root.previewText = "";
        root.previewImage = "";
        root.previewIsImage = false;
    }

    // refresh list + reset preview whenever the panel opens
    onClipboardOpenChanged: {
        if (clipboardOpen) {
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
                let firstId = "";
                let firstIsImage = false;

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
                    if (firstId === "") {
                        firstId = id;
                        firstIsImage = isImg;
                    }
                }
                // select + preview the most recent entry by default
                if (firstId !== "")
                    root.loadPreview(firstId, firstIsImage);
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
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }

                Text {
                    Layout.fillWidth: true
                    text: "Clipboard Menu"
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
                    font.pixelSize: Globals.textFont.pixelSize - 1
                    font.weight: Globals.textFont.weight

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -1
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wipeProc.running = true
                    }
                }
            }

            // empty state - keeps the menu as small as an empty notification menu
            Text {
                visible: clipModel.count === 0
                Layout.fillWidth: true
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

                // left: scrollable entry list
                Flickable {
                    Layout.preferredWidth: root.listWidth
                    Layout.preferredHeight: root.bodyHeight
                    clip: true
                    contentWidth: width
                    contentHeight: listColumn.implicitHeight
                    boundsBehavior: Flickable.StopAtBounds

                    ColumnLayout {
                        id: listColumn
                        width: parent.width
                        spacing: Globals.spacing

                        Repeater {
                            model: clipModel
                            delegate: Rectangle {
                                id: entry
                                required property string cid
                                required property string preview
                                required property bool isImage

                                Layout.fillWidth: true
                                implicitHeight: entryText.implicitHeight + (Globals.spacing + 2) * 2
                                radius: Globals.radius
                                // mirror PowerMenu's CenterTextBtn: no border, fill with fgColor
                                // when hovered or when this is the selected (previewed) entry
                                color: (ema.containsMouse || root.hoveredId === entry.cid) ? Globals.fgColor : "transparent"

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
                                        margins: Globals.spacing + 2
                                    }
                                    text: entry.preview
                                    color: (ema.containsMouse || root.hoveredId === entry.cid) ? Globals.bgColor : Globals.fgColor
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
                                    onEntered: root.loadPreview(entry.cid, entry.isImage)
                                    onClicked: {
                                        root.copyEntry(entry.cid);
                                        root.clipboardOpen = false;
                                    }
                                }
                            }
                        }
                    }
                }

                // thin divider between list and preview (equal top/bottom gaps)
                Rectangle {
                    Layout.preferredWidth: Globals.borderWidth
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
