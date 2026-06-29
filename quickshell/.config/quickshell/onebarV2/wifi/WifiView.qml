pragma ComponentBehavior: Bound

import Quickshell.Io
import qs.wifi
import qs.defaults

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    readonly property int menuWidth: 300

    // ----- state -----
    property bool wifiEnabled: true
    property var knownNetworks: []   // [{name,uuid,ssid,signalStrength,secured,enterprise,connected}]
    property var newNetworks: []     // [{ssid,signalStrength,secured,enterprise}]

    property string expandedKey: ""  // open row: uuid (known) | "new:"+ssid (new)
    property string passwordText: ""
    property string usernameText: ""
    property string focusedField: "password"   // "username" | "password"
    property bool revealPassword: false
    property string connectingKey: ""           // row with a connect/up in flight -> spinner

    readonly property bool menuOpen: Globals.wifiMenuOpen

    // raw nmcli output, merged into the section models by rebuild()
    property var _saved: []
    property var _scan: []

    function keyForKnown(uuid: string): string {
        return uuid;
    }
    function keyForNew(ssid: string): string {
        return "new:" + ssid;
    }

    function collapseForm(): void {
        root.expandedKey = "";
        root.passwordText = "";
        root.usernameText = "";
        root.revealPassword = false;
    }

    function expand(key: string, enterprise: bool): void {
        if (root.expandedKey === key) {
            root.collapseForm();
            return;
        }
        root.expandedKey = key;
        root.passwordText = "";
        root.usernameText = "";
        root.revealPassword = false;
        root.focusedField = enterprise ? "username" : "password";
    }

    // ----- readers -----
    function refresh(): void {
        radioProc.running = true;
        savedProc.running = true;
        scanProc.running = true;
    }

    function rescan(): void {
        root.scanning = true; // nmcli rescan returns instantly -> spin off a timed window, not the process
        rescanProc.running = true;
        scanWatchdog.restart();
    }

    // merge saved connections + scan results into the two section models
    function rebuild(): void {
        const savedNames = {};
        let known = [];
        for (const s of root._saved) {
            let match = null;
            for (const n of root._scan)
                if (n.ssid === s.name) {
                    match = n;
                    break;
                }
            savedNames[s.name] = true;
            known.push({
                name: s.name,
                uuid: s.uuid,
                ssid: s.name,
                signalStrength: match ? match.signalStrength : -1,
                secured: match ? match.secured : true,
                enterprise: match ? match.enterprise : false,
                connected: s.connected
            });
        }
        // new = scanned SSIDs not already saved, deduped keeping the strongest signal
        let seen = {};
        let fresh = [];
        for (const n of root._scan) {
            if (!n.ssid || savedNames[n.ssid])
                continue;
            if (seen[n.ssid] !== undefined) {
                if (n.signalStrength > fresh[seen[n.ssid]].signalStrength)
                    fresh[seen[n.ssid]] = n;
                continue;
            }
            seen[n.ssid] = fresh.length;
            fresh.push(n);
        }
        fresh.sort((a, b) => b.signalStrength - a.signalStrength);
        root.knownNetworks = known;
        root.newNetworks = fresh;
    }

    // ----- actions -----
    function toggleRadio(): void {
        radioToggleProc.command = ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"];
        radioToggleProc.running = true;
    }
    function connectKnown(net): void {
        root.connectingKey = root.keyForKnown(net.uuid);
        root.collapseForm();
        actionProc.command = ["nmcli", "connection", "up", "uuid", net.uuid];
        actionProc.running = true;
    }
    function disconnectKnown(net): void {
        root.collapseForm();
        actionProc.command = ["nmcli", "connection", "down", "uuid", net.uuid];
        actionProc.running = true;
    }
    function forgetKnown(net): void {
        root.collapseForm();
        actionProc.command = ["nmcli", "connection", "delete", "uuid", net.uuid];
        actionProc.running = true;
    }
    function connectNew(net): void {
        root.connectingKey = root.keyForNew(net.ssid);
        if (!net.secured) {
            actionProc.command = ["nmcli", "device", "wifi", "connect", net.ssid];
            actionProc.running = true;
        } else if (net.enterprise) {
            // 802.1X PEAP/MSCHAPv2 (the eduroam default at most institutions): add the profile carrying the credentials, then bring it up
            enterpriseProc.ssid = net.ssid;
            enterpriseProc.command = ["nmcli", "connection", "add", "type", "wifi", "con-name", net.ssid, "ssid", net.ssid, "wifi-sec.key-mgmt", "wpa-eap", "802-1x.eap", "peap", "802-1x.phase2-auth", "mschapv2", "802-1x.identity", root.usernameText, "802-1x.password", root.passwordText];
            enterpriseProc.running = true;
        } else {
            actionProc.command = ["nmcli", "device", "wifi", "connect", net.ssid, "password", root.passwordText];
            actionProc.running = true;
        }
        root.collapseForm();
    }

    // ----- keyboard (PopupWindow forwards every key via WifiMenu.onKeyDown) -----
    function expandedNewSecured() {
        if (!root.expandedKey.startsWith("new:"))
            return null;
        const ssid = root.expandedKey.slice(4);
        for (const n of root.newNetworks)
            if (n.ssid === ssid && n.secured)
                return n;
        return null;
    }

    function handleKey(event): void {
        const k = event.key;
        if (k === Qt.Key_Escape) {
            // collapse an open row first; an unaccepted Escape lets PopupWindow close
            if (root.expandedKey !== "") {
                root.collapseForm();
                event.accepted = true;
            }
            return;
        }
        const net = root.expandedNewSecured();
        if (!net)
            return;

        if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            root.connectNew(net);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Tab) {
            if (net.enterprise)
                root.focusedField = root.focusedField === "username" ? "password" : "username";
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Backspace) {
            if (root.focusedField === "username")
                root.usernameText = root.usernameText.slice(0, -1);
            else
                root.passwordText = root.passwordText.slice(0, -1);
            event.accepted = true;
            return;
        }
        if (event.text && event.text.length === 1 && event.text.charCodeAt(0) >= 0x20) {
            if (root.focusedField === "username")
                root.usernameText += event.text;
            else
                root.passwordText += event.text;
            event.accepted = true;
        }
    }

    // refresh as soon as the card opens; poll lightly while it stays open
    onMenuOpenChanged: {
        if (root.menuOpen) {
            root.collapseForm();
            root.refresh();
            root.rescan();
        }
    }
    Component.onCompleted: root.refresh()

    // ----- nmcli processes -----
    Process {
        id: radioProc
        command: ["nmcli", "-t", "-f", "WIFI", "radio"]
        stdout: StdioCollector {
            onStreamFinished: root.wifiEnabled = text.trim() === "enabled"
        }
    }

    Process {
        id: savedProc
        command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,ACTIVE,DEVICE", "connection", "show"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = [];
                for (const line of text.trim().split('\n')) {
                    if (!line)
                        continue;
                    const p = line.split(':');
                    if (p.length < 4 || p[2] !== "802-11-wireless")
                        continue;
                    out.push({
                        name: p[0],
                        uuid: p[1],
                        connected: p[3] === "yes"
                    });
                }
                root._saved = out;
                root.rebuild();
            }
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let out = [];
                for (const line of text.split('\n')) {
                    if (!line)
                        continue;
                    const p = line.split(':');
                    if (p.length < 3 || !p[1])
                        continue;
                    const sec = (p[3] || "").trim();
                    out.push({
                        ssid: p[1],
                        signalStrength: parseInt(p[2]) || 0,
                        secured: sec !== "" && sec !== "--",
                        enterprise: sec.includes("802.1X")
                    });
                }
                root._scan = out;
                root.rebuild();
            }
        }
    }

    // manual rescan -> re-list once it settles (the "Scanning not allowed" error
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onExited: (exitCode, exitStatus) => refreshTimer.restart()
    }

    Process {
        id: radioToggleProc
        onExited: (exitCode, exitStatus) => refreshTimer.restart()
    }

    // up / down / delete / connect; clears the spinner + refreshes on completion
    Process {
        id: actionProc
        onExited: (exitCode, exitStatus) => {
            root.connectingKey = "";
            refreshTimer.restart();
        }
    }

    // enterprise: `connection add` then `connection up` once the profile exists
    Process {
        id: enterpriseProc
        property string ssid: ""
        onExited: (exitCode, exitStatus) => {
            upProc.command = ["nmcli", "connection", "up", "id", enterpriseProc.ssid];
            upProc.running = true;
        }
    }
    Process {
        id: upProc
        onExited: (exitCode, exitStatus) => {
            root.connectingKey = "";
            refreshTimer.restart();
        }
    }

    property bool scanning: false
    Timer {
        id: scanWatchdog
        interval: 2800
        onTriggered: root.scanning = false
    }

    // debounce a re-read after an action so NetworkManager has settled
    Timer {
        id: refreshTimer
        interval: 1500
        onTriggered: root.refresh()
    }
    // keep signal levels + scan results fresh while the card is open
    Timer {
        interval: 8000
        repeat: true
        running: root.menuOpen
        onTriggered: root.refresh()
    }

    spacing: Globals.spacing

    // strut pinning the body width (matches the other cards so swaps don't jump)
    Item {
        Layout.preferredWidth: root.menuWidth
        Layout.preferredHeight: 0
    }

    // ----- header: icon + title + on/off toggle -----
    RowLayout {
        Layout.fillWidth: true
        spacing: Globals.spacing

        Text {
            text: String.fromCodePoint(root.wifiEnabled ? 0xF0928 : 0xF092E) // wifi / wifi-off-outline
            visible: Globals.headerIcons
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 18
            font.weight: Globals.textFont.weight
        }
        Text {
            Layout.fillWidth: true
            text: "Wi-Fi"
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 2
            font.weight: Globals.textFont.weight
        }

        Rectangle {
            id: toggle
            implicitWidth: Globals.textFont.pixelSize * 2.4
            implicitHeight: Globals.textFont.pixelSize * 1.3
            radius: height / 2
            color: root.wifiEnabled ? Globals.fgColor : (toggleArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.5) : "transparent")
            // border.width: 1
            // border.color: Qt.alpha(Globals.fgColor, 0.4)

            Behavior on color {
                ColorAnimation {
                    duration: Globals.animFast
                }
            }

            Rectangle {
                id: knob
                width: parent.height - 6
                height: width
                radius: width / 2
                y: 3
                x: root.wifiEnabled ? parent.width - width - 3 : 3
                color: root.wifiEnabled ? Globals.bgColor : Globals.fgColor

                Behavior on x {
                    NumberAnimation {
                        duration: Globals.animFast
                        easing.type: Easing.OutCubic
                    }
                }
            }

            MouseArea {
                id: toggleArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.toggleRadio()
            }
        }
    }

    MenuDivider {}

    // ----- wifi off fallback -----
    Text {
        visible: !root.wifiEnabled
        Layout.fillWidth: true
        text: "Wi-Fi is off"
        color: Qt.alpha(Globals.fgColor, 0.4)
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize - 1
        font.weight: Globals.textFont.weight - 100
        horizontalAlignment: Text.AlignHCenter
    }

    // ----- known networks -----
    Text {
        visible: root.wifiEnabled
        text: "Known networks"
        color: Qt.alpha(Globals.fgColor, 0.6)
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize - 1
        font.weight: Globals.textFont.weight
    }

    Repeater {
        model: root.knownNetworks
        delegate: WifiNetworkRow {
            required property var modelData
            visible: root.wifiEnabled
            ssid: modelData.ssid
            signalStrength: modelData.signalStrength
            secured: modelData.secured
            enterprise: modelData.enterprise
            known: true
            connected: modelData.connected
            busy: root.connectingKey === root.keyForKnown(modelData.uuid)
            expanded: root.expandedKey === root.keyForKnown(modelData.uuid)
            onToggleExpand: root.expand(root.keyForKnown(modelData.uuid), modelData.enterprise)
            onConnectRequested: root.connectKnown(modelData)
            onDisconnectRequested: root.disconnectKnown(modelData)
            onForgetRequested: root.forgetKnown(modelData)
        }
    }

    Text {
        visible: root.wifiEnabled && root.knownNetworks.length === 0
        Layout.fillWidth: true
        text: "No saved networks"
        color: Qt.alpha(Globals.fgColor, 0.35)
        font.family: Globals.textFont.family
        font.weight: Globals.textFont.weight
        font.pixelSize: Globals.textFont.pixelSize - 2
    }

    MenuDivider {
        visible: root.wifiEnabled
    }

    // ----- new networks + rescan -----
    RowLayout {
        visible: root.wifiEnabled
        Layout.fillWidth: true
        spacing: Globals.spacing

        Text {
            Layout.fillWidth: true
            text: "New networks"
            color: Qt.alpha(Globals.fgColor, 0.6)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 1
            font.weight: Globals.textFont.weight
        }

        // radar -> rescan; spins while scanning
        Text {
            text: String.fromCodePoint(0xF0437) // radar
            color: root.scanning ? Globals.fgColor : Qt.alpha(Globals.fgColor, 0.6)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 12
            font.weight: Globals.textFont.weight

            RotationAnimation on rotation {
                running: root.scanning
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Globals.spacing
                cursorShape: Qt.PointingHandCursor
                onClicked: root.rescan()
            }
        }
    }

    Repeater {
        model: root.newNetworks
        delegate: WifiNetworkRow {
            required property var modelData
            visible: root.wifiEnabled
            ssid: modelData.ssid
            signalStrength: modelData.signalStrength
            secured: modelData.secured
            enterprise: modelData.enterprise
            known: false
            connected: false
            busy: root.connectingKey === root.keyForNew(modelData.ssid)
            expanded: root.expandedKey === root.keyForNew(modelData.ssid)
            passwordText: root.passwordText
            usernameText: root.usernameText
            focusedField: root.focusedField
            revealPassword: root.revealPassword
            onToggleExpand: root.expand(root.keyForNew(modelData.ssid), modelData.enterprise)
            onConnectRequested: root.connectNew(modelData)
            onFocusField: field => root.focusedField = field
            onToggleReveal: root.revealPassword = !root.revealPassword
        }
    }

    Text {
        visible: root.wifiEnabled && root.newNetworks.length === 0
        Layout.fillWidth: true
        text: "Tap the radar to scan"
        color: Qt.alpha(Globals.fgColor, 0.35)
        font.family: Globals.textFont.family
        font.weight: Globals.textFont.weight - 100
        font.pixelSize: Globals.textFont.pixelSize - 2
    }
}
