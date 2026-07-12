pragma ComponentBehavior: Bound

import Quickshell.Bluetooth
import qs.menus.audio
import qs.templates

import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    readonly property int menuWidth: 280

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool hasAdapter: adapter !== null
    readonly property bool poweredOn: hasAdapter && adapter.enabled

    readonly property var allDevices: Bluetooth.devices ? Bluetooth.devices.values : [] // full device list

    function deviceBusy(d): bool {
        return d && (d.pairing || d.state === BluetoothDeviceState.Connecting || d.state === BluetoothDeviceState.Disconnecting);
    }
    // paired row: toggle the connection
    function activatePaired(d): void {
        if (!d)
            return;
        if (d.connected)
            d.disconnect();
        else
            d.connect();
    }
    // nearby row: pair (BlueZ auto-connects trusted devices after pairing)
    function activateNearby(d): void {
        if (!d)
            return;
        d.trusted = true;
        d.pair();
    }

    // stop scanning when we leave the bluetooth card
    Component.onDestruction: {
        if (root.adapter && root.adapter.discovering)
            root.adapter.discovering = false;
    }

    spacing: Globals.spacing

    // strut pinning the body width (matches AudioView so the swap doesn't jump)
    Item {
        Layout.preferredWidth: root.menuWidth
        Layout.preferredHeight: 0
    }

    // ----- header: icon + title + on/off toggle -----
    RowLayout {
        Layout.fillWidth: true
        spacing: Globals.spacing

        Text {
            text: String.fromCodePoint(root.poweredOn ? 0xF293 : 0xF00B2) // bluetooth / bluetooth-off
            visible: Globals.headerIcons
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 6
            font.weight: Globals.textFont.weight
        }
        Text {
            Layout.fillWidth: true
            text: "Bluetooth"
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 2
            font.weight: Globals.textFont.weight
        }

        // on/off switch -> follows CenterTextBtn colour logic (filled fg when active /
        // hovered, transparent otherwise)

        Rectangle {
            id: toggle
            enabled: root.hasAdapter
            opacity: enabled ? 1 : 0.4
            implicitWidth: Globals.textFont.pixelSize * 2.4
            implicitHeight: Globals.textFont.pixelSize * 1.3
            radius: height / 2
            color: root.poweredOn ? Globals.fgColor : (toggleArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.5) : "transparent")
            // borders off for now -> uncomment to re-enable
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
                x: root.poweredOn ? parent.width - width - 3 : 3
                color: root.poweredOn ? Globals.bgColor : Globals.fgColor

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
                onClicked: {
                    if (root.adapter)
                        root.adapter.enabled = !root.adapter.enabled;
                }
            }
        }
    }

    MenuDivider {}

    // ----- no adapter fallback -----
    Text {
        visible: !root.hasAdapter
        Layout.fillWidth: true
        text: "No Bluetooth adapter found"
        color: Qt.alpha(Globals.fgColor, 0.4)
        font.family: Globals.textFont.family
        font.weight: Globals.textFont.weight
        horizontalAlignment: Text.AlignHCenter
    }

    // ----- paired devices -----
    Text {
        visible: root.hasAdapter
        text: "Paired devices"
        color: Qt.alpha(Globals.fgColor, 0.6)
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize - 1
        font.weight: Globals.textFont.weight
    }

    Repeater {
        model: root.allDevices
        delegate: BtDeviceRow {
            required property var modelData
            visible: root.hasAdapter && modelData && modelData.paired
            deviceName: modelData ? modelData.name : ""
            iconName: modelData ? modelData.icon : ""
            connected: modelData ? modelData.connected : false
            busy: root.deviceBusy(modelData)
            batteryAvailable: modelData ? modelData.batteryAvailable : false
            battery: modelData ? modelData.battery : 0
            showForget: true // paired rows can be unpaired
            onActivated: root.activatePaired(modelData)
            onForgetRequested: if (modelData)
                modelData.forget()
        }
    }

    // ----- nearby devices + scan -----
    RowLayout {
        visible: root.hasAdapter
        Layout.fillWidth: true
        Layout.topMargin: Globals.spacing
        spacing: Globals.spacing

        Text {
            Layout.fillWidth: true
            text: "Nearby Devices"
            color: Qt.alpha(Globals.fgColor, 0.6)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 1
            font.weight: Globals.textFont.weight
        }

        // radar -> toggles discovery; spins while scanning
        Text {
            text: String.fromCodePoint(0xF0437) // radar
            color: root.adapter && root.adapter.discovering ? Globals.fgColor : Qt.alpha(Globals.fgColor, 0.6)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 1
            font.weight: Globals.textFont.weight

            RotationAnimation on rotation {
                running: root.adapter !== null && root.adapter.discovering
                from: 0
                to: 360
                duration: 2000
                loops: Animation.Infinite
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -Globals.spacing
                cursorShape: Qt.PointingHandCursor
                enabled: root.poweredOn
                onClicked: {
                    if (root.adapter)
                        root.adapter.discovering = !root.adapter.discovering;
                }
            }
        }
    }

    Repeater {
        model: root.allDevices
        delegate: BtDeviceRow {
            required property var modelData
            visible: root.hasAdapter && modelData && !modelData.paired
            deviceName: modelData ? modelData.name : ""
            iconName: modelData ? modelData.icon : ""
            connected: false
            busy: root.deviceBusy(modelData)
            onActivated: root.activateNearby(modelData)
        }
    }

    // hint for while the adapter is on but nothing has been discovered yet
    Text {
        visible: root.poweredOn && !root.adapter.discovering
        Layout.fillWidth: true
        text: "Tap the radar to scan"
        color: Qt.alpha(Globals.fgColor, 0.35)
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize - 2
    }

    // footer: switch back to the audio card (toggle hugs the right edge)
    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: Globals.spacing
        Item {
            Layout.fillWidth: true
        } // push the button to the right edge
        ViewSwitchBtn {
            icon: String.fromCodePoint(0xF0F70) // treble clef (matches the audio menu header)
            label: "Audio"
            onClicked: Globals.audioMenuView = "audio"
        }
    }
}
