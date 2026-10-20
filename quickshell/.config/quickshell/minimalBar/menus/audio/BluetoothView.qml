pragma ComponentBehavior: Bound

import Quickshell.Bluetooth
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
    readonly property var nearbyDevices: root.allDevices.filter(device => device && !device.paired && device.adapter === root.adapter)

    width: root.menuWidth
    spacing: 16

    function deviceBusy(device): bool {
        return device && (device.pairing || device.state === BluetoothDeviceState.Connecting || device.state === BluetoothDeviceState.Disconnecting);
    }

    function deviceStatus(device): string {
        if (!device)
            return "";
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
        if (device.connected)
            device.disconnect();
        else
            device.connect();
    }

    function activateNearby(device): void {
        if (!device || !root.poweredOn || root.deviceBusy(device))
            return;
        device.trusted = true;
        device.pair();
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
