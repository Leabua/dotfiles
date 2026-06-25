import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io

Rectangle {
    id: root

    implicitWidth: 360
    implicitHeight: Math.min(400, layout.implicitHeight)
    color: "transparent"

    readonly property var adapter: Bluetooth.defaultAdapter
    property bool powered: adapter && adapter.state !== BluetoothAdapterState.Off
    property bool scanning: false
    property string selectedMac: ""
    property var devices: []
    
    // PIN stuff
    property string pinPromptMac: ""
    property string pinInput: ""

    function refresh() {
        if (!getDevicesProc.running)
            getDevicesProc.running = true;
    }

    Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: scanTimer
        interval: 30000
        repeat: false
        onTriggered: {
            root.scanning = false;
            scanOffProc.running = true;
        }
    }

    Shortcut {
        sequence: "S"
        onActivated: {
            root.scanning = true;
            scanOnProc.running = true;
            scanTimer.restart();
        }
    }

    Shortcut {
        sequence: "U"
        onActivated: {
            if (root.selectedMac !== "") {
                removeProc.mac = root.selectedMac;
                removeProc.running = true;
            }
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.powered ? "󰂯 Bluetooth" : "󰂲 Bluetooth"
            font.family: global.shellFont.family
            font.pixelSize: 15
            font.bold: true
            color: global.fgColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.15)
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            Text {
                text: "󰂯"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: root.powered ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: togglePowerProc.running = true
                }
            }

            Text {
                text: "󰑐"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: root.scanning ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: {
                        root.scanning = true;
                        scanOnProc.running = true;
                        scanTimer.restart();
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.devices

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: root.pinPromptMac === modelData.mac ? 74 : 40
                    radius: 12
                    color: root.selectedMac === modelData.mac
                           ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.12)
                           : (hover.hovered ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.05) : "transparent")
                    border.color: root.selectedMac === modelData.mac ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.2) : "transparent"
                    border.width: 1

                    Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 150 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: modelData.paired ? "󰂱" : "󰂯"
                                font.family: global.shellFont.family
                                font.pixelSize: 16
                                color: global.fgColor
                                opacity: modelData.paired ? 1.0 : 0.5
                            }

                            Text {
                                text: modelData.name
                                font.family: global.shellFont.family
                                font.pixelSize: 13
                                font.bold: modelData.paired
                                color: global.fgColor
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                opacity: modelData.paired ? 1.0 : 0.8
                            }
                        }

                        // PIN Input Field
                        RowLayout {
                            visible: root.pinPromptMac === modelData.mac
                            Layout.fillWidth: true
                            spacing: 8

                            Rectangle {
                                Layout.fillWidth: true
                                implicitHeight: 28
                                radius: 8
                                color: Qt.rgba(0, 0, 0, 0.2)
                                border.color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.3)
                                border.width: 1

                                TextInput {
                                    anchors.fill: parent
                                    anchors.leftMargin: 10
                                    anchors.rightMargin: 10
                                    verticalAlignment: TextInput.AlignVCenter
                                    text: root.pinInput
                                    color: global.fgColor
                                    font.family: global.shellFont.family
                                    font.pixelSize: 13
                                    clip: true
                                    onTextEdited: root.pinInput = text
                                    onAccepted: {
                                        replyPinProc.pin = root.pinInput;
                                        replyPinProc.running = true;
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        text: "Enter PIN..."
                                        color: global.fgColor
                                        opacity: 0.4
                                        font: parent.font
                                        visible: parent.text === ""
                                    }
                                }
                            }

                            PillButton {
                                label: "Submit"
                                filled: true
                                onClicked: {
                                    replyPinProc.pin = root.pinInput;
                                    replyPinProc.running = true;
                                }
                            }
                        }
                    }

                    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }

                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            root.selectedMac = modelData.mac;
                            connectProc.mac = modelData.mac;
                            connectProc.running = true;
                        }
                    }

                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            root.selectedMac = modelData.mac;
                            removeProc.mac = modelData.mac;
                            removeProc.running = true;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: getDevicesProc
        command: ["bluetoothctl", "devices"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parsed = [];
                let lines = text.trim().split("\n");
                for (let line of lines) {
                    let parts = line.trim().split(" ");
                    if (parts.length >= 3 && parts[0] === "Device") {
                        parsed.push({ mac: parts[1], name: parts.slice(2).join(" "), paired: false });
                    }
                }
                
                // Now get paired devices to update status
                checkPairedProc.currentDevices = parsed;
                checkPairedProc.running = true;
            }
        }
    }

    Process {
        id: checkPairedProc
        property var currentDevices: []
        command: ["bluetoothctl", "devices", "Paired"]
        stdout: StdioCollector {
            onStreamFinished: {
                let pairedMacs = [];
                let lines = text.trim().split("\n");
                for (let line of lines) {
                    let parts = line.trim().split(" ");
                    if (parts.length >= 3 && parts[0] === "Device") {
                        pairedMacs.push(parts[1]);
                    }
                }
                
                for (let i = 0; i < checkPairedProc.currentDevices.length; i++) {
                    if (pairedMacs.includes(checkPairedProc.currentDevices[i].mac)) {
                        checkPairedProc.currentDevices[i].paired = true;
                    }
                }
                
                // Sort: Paired first
                checkPairedProc.currentDevices.sort((a, b) => {
                    if (a.paired && !b.paired) return -1;
                    if (!a.paired && b.paired) return 1;
                    return 0;
                });
                
                root.devices = checkPairedProc.currentDevices.slice(0, 8); // Limit to 8
            }
        }
    }

    Process {
        id: togglePowerProc
        command: ["bluetoothctl", "power", root.powered ? "off" : "on"]
        onRunningChanged: if (!running) root.refresh()
    }

    Process {
        id: scanOnProc
        command: ["bluetoothctl", "scan", "on"]
        onRunningChanged: if (!running) root.refresh()
    }

    Process {
        id: scanOffProc
        command: ["bluetoothctl", "scan", "off"]
        onRunningChanged: if (!running) root.refresh()
    }

    Process {
        id: connectProc
        property string mac: ""
        command: ["bash", "-c", "bluetoothctl connect " + mac + " | grep -i 'PIN'"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (text.toLowerCase().includes("pin")) {
                    root.pinPromptMac = connectProc.mac;
                } else {
                    root.refresh();
                }
            }
        }
    }
    
    Process {
        id: replyPinProc
        property string pin: ""
        command: ["bash", "-c", "echo '" + pin + "' | bluetoothctl"]
        onRunningChanged: {
            if (!running) {
                root.pinPromptMac = "";
                root.pinInput = "";
                root.refresh();
            }
        }
    }

    Process {
        id: removeProc
        property string mac: ""
        command: ["bluetoothctl", "remove", mac]
        onRunningChanged: {
            if (!running) {
                root.selectedMac = "";
                root.refresh();
            }
        }
    }
}
