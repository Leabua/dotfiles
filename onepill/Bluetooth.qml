pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Bluetooth
import QtQuick

StatusButton {
    id: btBtn

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var allDevices: Bluetooth.devices

    property bool isBtOn: adapter && adapter.state !== BluetoothAdapterState.Off
    property int connectedCount: {
        let count = 0;
        for (let i = 0; i < allDevices.count; i++) {
            if (allDevices.get(i).connected) count++;
        }
        return count;
    }

    isActive: isBtOn
    invertWhenOff: true

    icon: {
        if (!isBtOn) return "󰂲";
        return connectedCount > 0 ? "󰂱" : "󰂯";
    }

    label: isBtOn && connectedCount > 0 ? connectedCount.toString() : ""
}
