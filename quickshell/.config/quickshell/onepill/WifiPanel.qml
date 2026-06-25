import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    implicitWidth: 360
    implicitHeight: Math.min(420, layout.implicitHeight)
    color: "transparent"

    property bool enabled: false
    property var networks: []
    property string selectedSsid: ""
    property string passwordInput: ""

    function refresh() {
        if (!radioProc.running) radioProc.running = true;
        if (!getWifiProc.running) getWifiProc.running = true;
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Shortcut {
        sequence: "S"
        onActivated: {
            scanProc.running = true;
        }
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.enabled ? "󰤨 Wi-Fi" : "󰤮 Wi-Fi"
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
                text: "󰤨"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: root.enabled ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: toggleWifiProc.running = true
                }
            }

            Text {
                text: "󰑐"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: scanProc.running ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: scanProc.running = true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.networks

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: root.selectedSsid === modelData.ssid ? 74 : 40
                    radius: 12
                    color: root.selectedSsid === modelData.ssid
                           ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.12)
                           : (hover.hovered ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.05) : "transparent")
                    border.color: modelData.inUse ? "#a6e3a1" : (root.selectedSsid === modelData.ssid ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.2) : "transparent")
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
                                text: modelData.inUse ? "󰖩" : (modelData.security !== "" ? "󰖪" : "󰖩")
                                font.family: global.shellFont.family
                                font.pixelSize: 16
                                color: modelData.inUse ? "#a6e3a1" : global.fgColor
                            }

                            Text {
                                text: modelData.ssid
                                font.family: global.shellFont.family
                                font.pixelSize: 13
                                font.bold: modelData.inUse
                                color: modelData.inUse ? "#a6e3a1" : global.fgColor
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.signal + "%"
                                font.family: global.shellFont.family
                                font.pixelSize: 12
                                color: global.fgColor
                                opacity: 0.65
                            }
                        }

                        RowLayout {
                            visible: root.selectedSsid === modelData.ssid
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
                                    text: root.passwordInput
                                    echoMode: TextInput.Password
                                    color: global.fgColor
                                    selectionColor: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.3)
                                    font.family: global.shellFont.family
                                    font.pixelSize: 13
                                    clip: true
                                    onTextEdited: root.passwordInput = text
                                    onAccepted: {
                                        connectProc.ssid = modelData.ssid;
                                        connectProc.password = root.passwordInput;
                                        connectProc.running = true;
                                    }
                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                        text: "Password..."
                                        color: global.fgColor
                                        opacity: 0.4
                                        font: parent.font
                                        visible: parent.text === ""
                                    }
                                }
                            }

                            PillButton {
                                label: "Connect"
                                filled: true
                                onClicked: {
                                    connectProc.ssid = modelData.ssid;
                                    connectProc.password = root.passwordInput;
                                    connectProc.running = true;
                                }
                            }
                        }
                    }

                    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
                    
                    TapHandler {
                        acceptedButtons: Qt.LeftButton
                        onTapped: {
                            root.selectedSsid = root.selectedSsid === modelData.ssid ? "" : modelData.ssid;
                            root.passwordInput = "";
                        }
                    }
                    
                    TapHandler {
                        acceptedButtons: Qt.RightButton
                        onTapped: {
                            forgetProc.ssid = modelData.ssid;
                            forgetProc.running = true;
                        }
                    }
                }
            }
        }
    }

    Process {
        id: radioProc
        command: ["nmcli", "radio", "wifi"]
        stdout: StdioCollector {
            onStreamFinished: root.enabled = text.trim() === "enabled"
        }
    }

    Process {
        id: getWifiProc
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE", "dev", "wifi", "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                let parsed = [];
                let lines = text.trim().split("\n");
                for (let line of lines) {
                    let parts = line.split(":");
                    if (parts.length >= 4 && parts[0] !== "") {
                        let ssid = parts[0].replace(/\\:/g, ":");
                        if (!parsed.find(n => n.ssid === ssid)) {
                            parsed.push({
                                ssid: ssid,
                                signal: parseInt(parts[1]) || 0,
                                security: parts[2],
                                inUse: parts[3] === "*"
                            });
                        }
                    }
                }
                parsed.sort((a, b) => {
                    if (a.inUse && !b.inUse) return -1;
                    if (!a.inUse && b.inUse) return 1;
                    return b.signal - a.signal;
                });
                root.networks = parsed.slice(0, 7);
            }
        }
    }

    Process {
        id: scanProc
        command: ["nmcli", "dev", "wifi", "rescan"]
        onRunningChanged: if (!running) root.refresh()
    }

    Process {
        id: toggleWifiProc
        command: ["nmcli", "radio", "wifi", root.enabled ? "off" : "on"]
        onRunningChanged: if (!running) root.refresh()
    }

    Process {
        id: connectProc
        property string ssid: ""
        property string password: ""
        command: password !== "" ? ["nmcli", "dev", "wifi", "connect", ssid, "password", password]
                                 : ["nmcli", "dev", "wifi", "connect", ssid]
        onRunningChanged: {
            if (!running) {
                root.selectedSsid = "";
                root.passwordInput = "";
                root.refresh();
            }
        }
    }

    Process {
        id: forgetProc
        property string ssid: ""
        command: ["nmcli", "connection", "delete", "id", ssid]
        onRunningChanged: if (!running) root.refresh()
    }
}
