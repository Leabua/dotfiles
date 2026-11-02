pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates
import qs.menus.preview

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

// Quick look for one file, opened from Thunar (Ctrl+Space -> `ipc call preview toggle <path>`).
//   image   -> fitted, animated GIFs play
//   video   -> plays in place with MediaControls
//   audio   -> tags + MediaControls
//   pdf     -> pdftoppm renders one page at a time, ← / → to turn
//   text    -> first 256 KiB in the terminal's font
//   folder  -> its entries
// Keys: Space play / pause · ← → seek 5 s or turn page · ↑ ↓ volume · M mute · Return open in app

Scope {
    id: root

    property bool previewOpen: false
    property string path: ""
    property string kind: "" // image | video | audio | pdf | text | folder | other
    property string contentType: ""
    property real fileSize: -1
    property string loadError: ""
    property int request: 0 // bumps per file so a slow reply can't land on the next one

    // per-kind payloads
    property string text: ""
    property bool textTruncated: false
    property var entries: []
    property int pdfPage: 1
    property int pdfPages: 0
    property string pdfImage: ""
    property bool pdfRendering: false

    readonly property string name: path.substring(path.lastIndexOf("/") + 1)
    readonly property string extension: name.lastIndexOf(".") > 0 ? name.substring(name.lastIndexOf(".") + 1).toLowerCase() : ""
    readonly property bool isMedia: kind === "video" || kind === "audio"
    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") + "/qs-preview"

    // ----- sizing: the card hugs the content's aspect, never narrower than its header needs -----
    readonly property int maxCardWidth: Math.min(940, popup.availableWidth)
    readonly property int cardWidth: contentAspect > 0 ? Math.max(Math.min(520, maxCardWidth), Math.min(maxCardWidth, Math.round(maxWellHeight * contentAspect))) : maxCardWidth
    readonly property int wellWidth: cardWidth
    readonly property int maxWellHeight: Math.max(220, Math.min(600, popup.availableHeight - 170))
    readonly property real contentAspect: {
        if (kind === "image" && imageView.implicitHeight > 0)
            return imageView.implicitWidth / imageView.implicitHeight;
        if (kind === "video" && videoView.sourceRect.height > 0)
            return videoView.sourceRect.width / videoView.sourceRect.height;
        if (kind === "pdf" && pdfView.implicitHeight > 0)
            return pdfView.implicitWidth / pdfView.implicitHeight;
        return 0;
    }
    readonly property int wellHeight: {
        if (kind === "audio" || kind === "other")
            return 220;
        if (contentAspect > 0)
            return Math.round(Math.min(maxWellHeight, Math.max(220, wellWidth / contentAspect)));
        return maxWellHeight;
    }

    readonly property var textTypes: /^(text\/|application\/(json|xml|javascript|x-shellscript|x-yaml|yaml|toml|x-toml|sql|x-perl|x-php|x-ruby|x-python|x-desktop|x-nix|x-subrip|x-trash))|\+xml$|\+json$/

    function fileUrl(p: string): string {
        return "file://" + p.split("/").map(encodeURIComponent).join("/");
    }

    function classify(type: string, isDir: bool): string {
        if (isDir)
            return "folder";
        if (type === "image/gif" || /^image\/(png|jpeg|webp|bmp|svg\+xml|tiff|avif|x-icon|vnd\.microsoft\.icon|x-portable)/.test(type))
            return "image";
        if (type.startsWith("video/"))
            return "video";
        if (type.startsWith("audio/") || type === "application/ogg")
            return "audio";
        if (type === "application/pdf")
            return "pdf";
        if (textTypes.test(type) || type === "application/x-zerosize")
            return "text";
        return "other";
    }

    function typeLabel(): string {
        const ext = root.extension.toUpperCase();
        switch (root.kind) {
        case "folder":
            return "Folder";
        case "image":
            return (ext || "Image") + " image";
        case "video":
            return (ext || "Video") + " video";
        case "audio":
            return (ext || "Audio") + " audio";
        case "pdf":
            return "PDF document";
        case "text":
            return ext ? ext + " file" : "Plain text";
        default:
            return ext ? ext + " file" : root.contentType || "File";
        }
    }

    function humanSize(bytes: real): string {
        if (bytes < 0)
            return "";
        const units = ["bytes", "KB", "MB", "GB", "TB"];
        let i = 0;
        let n = bytes;
        while (n >= 1000 && i < units.length - 1) {
            n /= 1000;
            i++;
        }
        return (i === 0 ? n : n.toFixed(n < 10 ? 1 : 0)) + " " + units[i];
    }

    // the line under the title: type, then whatever the content knows about itself
    function detailLine(): string {
        const parts = [root.typeLabel()];
        if (root.kind === "image" && imageView.implicitWidth > 0)
            parts.push(imageView.implicitWidth + " × " + imageView.implicitHeight);
        if (root.kind === "video" && videoView.sourceRect.width > 0)
            parts.push(videoView.sourceRect.width + " × " + videoView.sourceRect.height);
        if (root.isMedia && player.duration > 0)
            parts.push(controls.clock(player.duration));
        if (root.kind === "pdf" && root.pdfPages > 0)
            parts.push(root.pdfPages === 1 ? "1 page" : root.pdfPages + " pages");
        if (root.kind === "text" && root.text !== "") {
            const lines = root.text.split("\n").length;
            parts.push(lines.toLocaleString() + (root.textTruncated ? "+ lines" : lines === 1 ? " line" : " lines"));
        }
        if (root.kind === "folder")
            parts.push(root.entries.length === 1 ? "1 item" : root.entries.length + " items");
        if (root.kind !== "folder")
            parts.push(root.humanSize(root.fileSize));
        return parts.filter(p => p !== "").join(", ");
    }

    function headerIcon(): string {
        return ({
                folder: "folder",
                image: "image",
                video: "film",
                audio: "music",
                pdf: "book",
                text: "code"
            })[root.kind] || "file";
    }

    // ----- lifecycle -----
    function openPath(p: string): void {
        if (p === "")
            return;
        root.reset();
        root.request++;
        root.path = p;
        root.previewOpen = true;
        infoProc.command = ["sh", "-c", 'stat -L -c "%s\t%F" -- "$1" && gio info -a standard::content-type -- "$1" | sed -n "s/^ *standard::content-type: //p"', "info", p];
        infoProc.running = true;
    }

    function reset(): void {
        player.stop();
        player.source = "";
        root.kind = "";
        root.contentType = "";
        root.fileSize = -1;
        root.loadError = "";
        root.text = "";
        root.textTruncated = false;
        root.entries = [];
        root.pdfPage = 1;
        root.pdfPages = 0;
        root.pdfImage = "";
    }

    function close(): void {
        root.previewOpen = false;
        player.stop();
        player.source = "";
    }

    function load(): void {
        switch (root.kind) {
        case "video":
        case "audio":
            player.source = root.fileUrl(root.path);
            player.play();
            break;
        case "text":
            textProc.command = ["sh", "-c", 'head -c 262145 -- "$1"', "text", root.path];
            textProc.running = true;
            break;
        case "folder":
            listProc.command = ["ls", "-1Ap", "--group-directories-first", "--", root.path];
            listProc.running = true;
            break;
        case "pdf":
            pagesProc.command = ["sh", "-c", 'pdfinfo -- "$1" | sed -n "s/^Pages: *//p"', "pages", root.path];
            pagesProc.running = true;
            root.renderPage(1);
            break;
        }
    }

    function renderPage(page: int): void {
        if (page < 1 || (root.pdfPages > 0 && page > root.pdfPages))
            return;
        root.pdfPage = page;
        if (pdfProc.running)
            return; // the finished render picks up the newest page
        const out = root.runtimeDir + "/page-" + root.request + "-" + page;
        pdfProc.page = page;
        pdfProc.out = out;
        pdfProc.command = ["sh", "-c", 'mkdir -p "$(dirname "$3")" && pdftoppm -f "$2" -l "$2" -png -singlefile -scale-to 1800 -- "$1" "$3"', "pdf", root.path, String(page), out];
        root.pdfRendering = true;
        pdfProc.running = true;
    }

    function openExternally(): void {
        Quickshell.execDetached(["xdg-open", root.path]);
        root.close();
    }

    function handleKey(event): void {
        const k = event.key;
        if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            root.openExternally();
        } else if (root.isMedia && (k === Qt.Key_Space || k === Qt.Key_K)) {
            controls.togglePlay();
        } else if (root.isMedia && k === Qt.Key_Left) {
            controls.seekBy(-5000);
        } else if (root.isMedia && k === Qt.Key_Right) {
            controls.seekBy(5000);
        } else if (root.isMedia && k === Qt.Key_Up) {
            controls.nudgeVolume(0.05);
        } else if (root.isMedia && k === Qt.Key_Down) {
            controls.nudgeVolume(-0.05);
        } else if (root.isMedia && k === Qt.Key_M) {
            audioOut.muted = !audioOut.muted;
        } else if (root.kind === "pdf" && (k === Qt.Key_Left || k === Qt.Key_PageUp)) {
            root.renderPage(root.pdfPage - 1);
        } else if (root.kind === "pdf" && (k === Qt.Key_Right || k === Qt.Key_PageDown || k === Qt.Key_Space)) {
            root.renderPage(root.pdfPage + 1);
        } else {
            return;
        }
        event.accepted = true;
    }

    // ----- backends -----
    Process {
        id: infoProc
        property int forRequest: 0
        onStarted: forRequest = root.request
        stdout: StdioCollector {
            onStreamFinished: {
                if (infoProc.forRequest !== root.request)
                    return;
                const lines = text.trim().split("\n");
                const stat = (lines[0] || "").split("\t");
                root.fileSize = Number(stat[0]);
                root.contentType = (lines[1] || "").trim();
                root.kind = root.classify(root.contentType, (stat[1] || "") === "directory");
                root.load();
            }
        }
        onExited: (code, status) => {
            if (code !== 0 && infoProc.forRequest === root.request) {
                root.kind = "other";
                root.loadError = "Can't read this file. It may have moved or been deleted.";
            }
        }
    }

    Process {
        id: textProc
        property int forRequest: 0
        onStarted: forRequest = root.request
        stdout: StdioCollector {
            onStreamFinished: {
                if (textProc.forRequest !== root.request)
                    return;
                root.textTruncated = text.length > 262144;
                root.text = root.textTruncated ? text.substring(0, 262144) : text;
            }
        }
    }

    Process {
        id: listProc
        property int forRequest: 0
        onStarted: forRequest = root.request
        stdout: StdioCollector {
            onStreamFinished: {
                if (listProc.forRequest !== root.request)
                    return;
                root.entries = text.split("\n").filter(line => line !== "").map(line => ({
                            name: line.replace(/\/$/, ""),
                            dir: line.endsWith("/")
                        }));
            }
        }
    }

    Process {
        id: pagesProc
        property int forRequest: 0
        onStarted: forRequest = root.request
        stdout: StdioCollector {
            onStreamFinished: {
                if (pagesProc.forRequest === root.request)
                    root.pdfPages = Number(text.trim()) || 0;
            }
        }
    }

    Process {
        id: pdfProc
        property int page: 0
        property string out: ""
        property int forRequest: 0
        onStarted: forRequest = root.request
        onExited: (code, status) => {
            root.pdfRendering = false;
            if (forRequest !== root.request)
                return;
            if (code === 0)
                root.pdfImage = root.fileUrl(out + ".png");
            else
                root.loadError = "This PDF couldn't be rendered.";
            if (root.pdfPage !== page)
                root.renderPage(root.pdfPage);
        }
    }

    // clear rendered pages once the card closes
    Process {
        id: cleanProc
        command: ["sh", "-c", 'rm -rf -- "$1"', "clean", root.runtimeDir]
    }
    onPreviewOpenChanged: {
        if (!previewOpen)
            cleanProc.running = true;
    }

    MediaPlayer {
        id: player
        audioOutput: AudioOutput {
            id: audioOut
            volume: 0.8
        }
        videoOutput: videoView
        onErrorOccurred: (error, message) => root.loadError = message || "This file can't be played."
    }

    IpcHandler {
        target: "preview"
        // same file again closes it, so one key both opens and dismisses
        function toggle(path: string): void {
            if (root.previewOpen && path === root.path)
                root.close();
            else
                root.openPath(path);
        }
        function open(path: string): void {
            root.openPath(path);
        }
        function hide(): void {
            root.close();
        }
    }

    PopupWindow {
        id: popup
        open: root.previewOpen
        onDismissed: root.close()
        onKeyDown: event => root.handleKey(event)
        hAlign: "center"
        verticallyCentered: true
        padding: 16
        backgroundColor: Globals.bgColor

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            left: Globals.marginsLeft
            right: Globals.marginsRight
        }

        ColumnLayout {
            width: root.cardWidth
            spacing: 12

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                MenuHeader {
                    title: root.name
                    icon: root.headerIcon()
                    actionText: "Open in app"
                    actionIcon: "external"
                    onActionClicked: root.openExternally()
                    onCloseRequested: root.close()
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: Globals.headerIcons ? 42 : 10 // under the title, past the glyph column
                    text: root.kind === "" ? "" : root.detailLine()
                    color: Qt.alpha(Globals.fgColor, 0.45)
                    font.family: Globals.textFont.family
                    font.pixelSize: 12
                    elide: Text.ElideRight
                }
            }

            // ----- the well: content sits on a slightly deeper ground, like the clipboard preview -----
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.wellHeight
                radius: 12
                color: Qt.darker(Globals.bgColor, 1.2)
                border.width: 1
                border.color: Qt.alpha(Globals.fgColor, 0.045)
                clip: true

                AnimatedImage {
                    id: imageView
                    anchors.fill: parent
                    anchors.margins: 1
                    visible: root.kind === "image"
                    source: root.kind === "image" ? root.fileUrl(root.path) : ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    smooth: true
                    mipmap: true
                    playing: visible
                }

                VideoOutput {
                    id: videoView
                    anchors.fill: parent
                    visible: root.kind === "video"
                    fillMode: VideoOutput.PreserveAspectFit

                    TapHandler {
                        onTapped: controls.togglePlay()
                        onDoubleTapped: root.openExternally()
                    }
                }

                // audio: the tags, large, where the picture would be
                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - 64
                    visible: root.kind === "audio"
                    spacing: 6

                    MenuIcon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 44
                        Layout.preferredHeight: 44
                        Layout.bottomMargin: 10
                        name: "music"
                        color: Qt.alpha(Globals.fgColor, 0.7)
                        strokeWidth: 1.4
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: player.metaData.stringValue(MediaMetaData.Title) || root.name.replace(/\.[^.]+$/, "")
                        color: Globals.fgColor
                        font.family: Globals.textFont.family
                        font.pixelSize: 20
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: text !== ""
                        text: [player.metaData.stringValue(MediaMetaData.ContributingArtist) || player.metaData.stringValue(MediaMetaData.AlbumArtist), player.metaData.stringValue(MediaMetaData.AlbumTitle)].filter(s => s).join(", ")
                        color: Qt.alpha(Globals.fgColor, 0.6)
                        font.family: Globals.textFont.family
                        font.pixelSize: 14
                        elide: Text.ElideRight
                    }
                }

                Image {
                    id: pdfView
                    anchors.fill: parent
                    anchors.margins: 1
                    visible: root.kind === "pdf"
                    source: root.pdfImage
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    cache: false
                    smooth: true
                    mipmap: true
                }

                Flickable {
                    id: textScroll
                    anchors.fill: parent
                    anchors.margins: 16
                    visible: root.kind === "text"
                    clip: true
                    contentWidth: width
                    contentHeight: textBody.contentHeight
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    TextEdit {
                        id: textBody
                        width: textScroll.width
                        text: root.text
                        readOnly: true
                        selectByMouse: true
                        textFormat: TextEdit.PlainText
                        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
                        color: Qt.alpha(Globals.fgColor, 0.88)
                        selectionColor: Qt.alpha(Globals.fgColor, 0.25)
                        selectedTextColor: Globals.fgColor
                        font.family: "Maple Mono NF" // the terminal's face, so code reads the way it does in nvim
                        font.pixelSize: 13
                        Keys.onPressed: event => {
                            event.accepted = false;
                            root.handleKey(event);
                            if (!event.accepted && event.key === Qt.Key_Escape)
                                root.close();
                        }
                    }
                }

                ListView {
                    id: folderList
                    anchors.fill: parent
                    anchors.margins: 6
                    visible: root.kind === "folder"
                    clip: true
                    model: root.entries
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }

                    delegate: RowLayout {
                        id: entry
                        required property var modelData
                        width: folderList.width
                        height: 34
                        spacing: 10

                        MenuIcon {
                            Layout.leftMargin: 10
                            Layout.preferredWidth: 18
                            Layout.preferredHeight: 18
                            name: entry.modelData.dir ? "folder" : "file"
                            color: Qt.alpha(Globals.fgColor, entry.modelData.dir ? 0.9 : 0.6)
                        }
                        Text {
                            Layout.fillWidth: true
                            text: entry.modelData.name
                            color: Globals.fgColor
                            font.family: Globals.textFont.family
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            elide: Text.ElideMiddle
                        }
                    }
                }

                // no preview, an empty folder, a failure: say what happened and what to do
                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width - 64
                    spacing: 6
                    visible: root.loadError !== "" || root.kind === "other" || (root.kind === "folder" && root.entries.length === 0 && !listProc.running)

                    MenuIcon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 40
                        Layout.bottomMargin: 8
                        name: root.kind === "folder" ? "folder" : "file"
                        color: Qt.alpha(Globals.fgColor, 0.6)
                        strokeWidth: 1.4
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: root.loadError !== "" ? root.loadError : root.kind === "folder" ? "This folder is empty" : "No preview for this file type"
                        color: Globals.fgColor
                        font.family: Globals.textFont.family
                        font.pixelSize: 15
                        font.weight: Font.DemiBold
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        visible: root.kind !== "folder"
                        text: "Press Return to open it in its app."
                        color: Qt.alpha(Globals.fgColor, 0.5)
                        font.family: Globals.textFont.family
                        font.pixelSize: 13
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: root.loadError === "" && (root.kind === "" || (root.kind === "pdf" && root.pdfImage === "") || (root.kind === "text" && textProc.running) || (root.kind === "image" && imageView.status === Image.Loading))
                    text: "Loading preview…"
                    color: Qt.alpha(Globals.fgColor, 0.4)
                    font.family: Globals.textFont.family
                    font.pixelSize: 13
                }
            }

            MediaControls {
                id: controls
                visible: root.isMedia
                player: player
                audio: audioOut
            }

            // page turner
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                visible: root.kind === "pdf" && root.pdfPages > 1
                spacing: 8

                TransportButton {
                    icon: "chevronLeft"
                    enabled: root.pdfPage > 1
                    onClicked: root.renderPage(root.pdfPage - 1)
                }
                Text {
                    text: "Page " + root.pdfPage + " of " + root.pdfPages
                    color: Qt.alpha(Globals.fgColor, 0.6)
                    font.family: Globals.textFont.family
                    font.pixelSize: 13
                    font.features: { "tnum": 1 }
                }
                TransportButton {
                    icon: "chevronRight"
                    enabled: root.pdfPage < root.pdfPages
                    onClicked: root.renderPage(root.pdfPage + 1)
                }
            }
        }
    }
}
