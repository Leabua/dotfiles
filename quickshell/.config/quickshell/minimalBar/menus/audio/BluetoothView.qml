pragma ComponentBehavior: Bound

import Quickshell.Bluetooth
import Quickshell.Io
import qs.menus.audio
import qs.templates
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property int availableWidth: 360
    readonly property int menuWidth: Math.min(360, availableWidth)
    property var adapter: Bluetooth.defaultAdapter
    property var allDevices: Bluetooth.devices ? Bluetooth.devices.values : []
    readonly property bool hasAdapter: root.adapter !== null && root.adapter !== undefined
    readonly property bool poweredOn: root.hasAdapter && root.adapter.enabled
    readonly property var pairedDevices: root.allDevices.filter(device => device && device.paired && device.adapter === root.adapter)
    // a scan picks up every anonymous BLE beacon in range, and with no advertised name BlueZ aliases them
    // to their MAC -> only list devices that name themselves (anything you'd actually pair does)
    readonly property var nearbyDevices: root.allDevices.filter(device => device && !device.paired && device.adapter === root.adapter && root.isNamed(device))

    function isNamed(device): bool {
        const name = (device.deviceName || "").trim();
        return name !== "" && !/^([0-9A-F]{2}[-:]){5}[0-9A-F]{2}$/i.test(name);
    }

    width: root.menuWidth
    spacing: 16

    function deviceBusy(device): bool {
        return device && (device.pairing || device.address === root.pairingAddress || device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting);
    }

    function deviceStatus(device): string {
        if (!device)
            return "";
        if (device.address === root.pairingAddress)
            return root.pairingStage === "connect" ? "Connecting…" : "Pairing…";
        if (device.pairing)
            return "Pairing…";
        if (device.state === BluetoothDeviceState.Connecting)
            return "Connecting…";
        if (device.state === BluetoothDeviceState.Disconnecting)
            return "Disconnecting…";
        return device.connected ? "Connected" : device.paired ? "Not connected" : "Not paired";
    }

    function activatePaired(device): void {
        if (!device || !root.poweredOn || root.deviceBusy(device))
            return;
        root.notice = "";
        if (device.connected) {
            device.disconnect();
        } else {
            root.connectingAddress = device.address;
            device.connect();
        }
    }

    // ----- pairing -----
    // BlueZ asks a pairing agent to confirm the passkey, and nothing on this system provides one
    // (no blueman), so device.pair() sat on that prompt until the device gave up ~30s later.
    // Pairing started here runs through bluetoothctl instead: it registers an agent only for this
    // session, confirms only the device you clicked, then trusts + connects it. Bonded + trusted
    // devices reconnect on their own afterwards without asking again.
    property string pairingAddress: ""
    property string pairingName: ""
    property string pairingStage: ""     // "pair" | "connect" while pairProc runs
    property string pairOutput: ""       // unconsumed bluetoothctl output
    property string connectingAddress: "" // paired device we asked to connect; watched for a failed attempt
    property string notice: ""           // what went wrong last, in plain words

    function activateNearby(device): void {
        if (!device || !root.poweredOn || root.deviceBusy(device) || pairProc.running)
            return;
        root.stopScanning(); // discovery running during pairing makes devices flaky
        root.notice = "";
        root.pairingAddress = device.address;
        root.pairingName = device.name;
        root.pairingStage = "pair";
        root.pairOutput = "";
        pairProc.running = true;
    }

    function readPairOutput(data: string): void {
        // prompts like "Confirm passkey 123456 (yes/no):" arrive without a newline, so read raw chunks
        root.pairOutput = (root.pairOutput + data.replace(/\x1b\[[0-9;]*[A-Za-z]|\r/g, "")).slice(-2000);
        const out = root.pairOutput;
        if (/Confirm passkey|Authorize service|Request authorization/.test(out)) {
            root.pairOutput = "";
            pairProc.write("yes\n");
        } else if (root.pairingStage === "pair" && out.includes("Pairing successful")) {
            root.pairOutput = "";
            root.pairingStage = "connect";
            pairProc.write("trust " + root.pairingAddress + "\n");
            pairProc.write("connect " + root.pairingAddress + "\n");
        } else if (out.includes("Connection successful")) {
            root.finishPairing("");
        } else if (out.includes("Failed to pair")) {
            root.finishPairing("Couldn't pair with " + root.pairingName + ". Put it in pairing mode, disconnect it from any other phone or computer, and try again.");
        } else if (out.includes("Failed to connect")) {
            root.finishPairing("Paired with " + root.pairingName + ", but it didn't connect. Make sure it's on and not playing from another device, then click it again.");
        }
    }

    function finishPairing(message: string): void {
        root.notice = message;
        root.pairOutput = "";
        if (pairProc.running)
            pairProc.write("quit\n");
    }

    Process {
        id: pairProc
        command: ["bluetoothctl"]
        stdinEnabled: true
        onStarted: {
            write("agent NoInputNoOutput\n");
            write("default-agent\n");
            write("pair " + root.pairingAddress + "\n");
        }
        stdout: SplitParser {
            splitMarker: "" // raw chunks -> see readPairOutput
            onRead: data => root.readPairOutput(data)
        }
        onExited: {
            root.pairingAddress = "";
            root.pairingStage = "";
        }
    }

    // a device that never answers leaves bluetoothctl waiting; give up with a reason instead
    Timer {
        interval: 45000
        running: pairProc.running
        onTriggered: {
            root.finishPairing("Couldn't reach " + root.pairingName + ". Put it in pairing mode and try again.");
            pairProc.running = false;
        }
    }

    function togglePower(): void {
        if (root.adapter) {
            if (root.adapter.enabled)
                root.stopScanning();
            root.adapter.enabled = !root.adapter.enabled;
        }
    }

    function toggleScan(): void {
        if (root.poweredOn)
            root.adapter.discovering = !root.adapter.discovering;
    }

    function stopScanning(): void {
        if (root.adapter && root.adapter.discovering)
            root.adapter.discovering = false;
    }

    Component.onDestruction: root.stopScanning()

    Connections {
        target: Globals
        function onAudioMenuOpenChanged(): void {
            if (!Globals.audioMenuOpen)
                root.stopScanning();
            else
                root.notice = "";
        }
    }

    MenuHeader {
        title: "Bluetooth"
        icon: "bluetooth"
        actionText: "Audio"
        actionIcon: "speaker"
        showToggle: true
        checked: root.poweredOn
        toggleEnabled: root.hasAdapter
        onActionClicked: Globals.audioMenuView = "audio"
        onToggleRequested: root.togglePower()
        onCloseRequested: Globals.audioMenuOpen = false
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        visible: !root.hasAdapter || !root.poweredOn
        text: root.hasAdapter ? "Bluetooth is off" : "No Bluetooth adapter found"
        color: Qt.alpha(Globals.fgColor, 0.5)
        font.family: Globals.textFont.family
        font.pixelSize: 13
    }

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        visible: root.notice !== ""
        text: root.notice
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
        color: Globals.criticalColor
        font.family: Globals.textFont.family
        font.pixelSize: 13
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.poweredOn && root.pairedDevices.length > 0
        spacing: 4

        MenuSectionLabel {
            Layout.bottomMargin: 4
            text: "Paired devices"
        }

        Repeater {
            model: root.pairedDevices

            delegate: BtDeviceRow {
                required property var modelData
                deviceName: modelData.name
                iconName: modelData.icon
                connected: modelData.connected
                busy: root.deviceBusy(modelData)
                statusText: root.deviceStatus(modelData)
                batteryAvailable: modelData.batteryAvailable
                battery: modelData.battery
                showForget: true
                onActivated: root.activatePaired(modelData)
                onForgetRequested: if (!root.deviceBusy(modelData)) modelData.forget()

                Connections {
                    target: modelData
                    function onStateChanged(): void {
                        if (root.connectingAddress !== modelData.address)
                            return;
                        if (modelData.connected) {
                            root.connectingAddress = "";
                        } else if (modelData.state === BluetoothDeviceState.Disconnected) {
                            root.connectingAddress = "";
                            root.notice = "Couldn't connect to " + modelData.name + ". Make sure it's on, in range, and not connected to another device.";
                        }
                    }
                }
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        visible: root.poweredOn
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            spacing: 8

            MenuSectionLabel {
                Layout.fillWidth: true
                inset: 0
                text: "Nearby devices"
            }

            MenuButton {
                text: root.adapter && root.adapter.discovering ? "Stop" : "Scan"
                onClicked: root.toggleScan()
            }
        }

        Repeater {
            model: root.nearbyDevices

            delegate: BtDeviceRow {
                required property var modelData
                deviceName: modelData.name
                iconName: modelData.icon
                connected: modelData.connected
                busy: root.deviceBusy(modelData)
                statusText: root.deviceStatus(modelData)
                onActivated: root.activateNearby(modelData)
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.topMargin: 4
            visible: root.nearbyDevices.length === 0
            text: root.adapter && root.adapter.discovering ? "Searching for devices…" : "No nearby devices"
            color: Qt.alpha(Globals.fgColor, 0.5)
            font.family: Globals.textFont.family
            font.pixelSize: 13
        }
    }
}
