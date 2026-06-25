import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire

ShellRoot {
    PanelWindow {
        id: global
        // property color bgColor: "#1e1e1e"
        // property color fgColor: "#FFFFFF"
        // property color borderColor: "#dcdcdc"

        // FileView {
        //     id: matugenColors
        //     path: "/home/leabua/.config/noctalia/colors.json"
        //     onTextChanged: {
        //         try {
        //             let colors = JSON.parse(text);
        //             if (colors.mOnSurface) {
        //                 global.fgColor = colors.mOnSurface;
        //             }
        //         } catch (e) {
        //             console.log("Failed to parse matugen colors from FileView");
        //         }
        //     }
        // }

        // property font shellFont: Qt.font({
        //     family: "Noto Sans",
        //     letterSpacing: 1,
        //     pixelSize: 15,
        //     weight: Font.Bold,
        //     bold: true
        // })

        PwObjectTracker {
            objects: [Pipewire.defaultAudioSink]
        }

        Connections {
            target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
            ignoreUnknownSignals: true

            function onVolumeChanged() {
                global.showVolumeOsd = true;
                osdTimer.restart();
            }
        }

        Process {
            id: getBrightnessProc
            command: ["brightnessctl", "-m"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    let parts = text.trim().split(",");
                    if (parts.length >= 4) {
                        let pctStr = parts[3].replace("%", "");
                        let pct = parseInt(pctStr) / 100.0;
                        global.brightnessVal = pct;
                    }
                }
            }
        }

        Process {
            id: changeBrightnessProc
            command: ["brightnessctl", "-m"]
            running: false
            stdout: StdioCollector {
                onStreamFinished: {
                    let parts = text.trim().split(",");
                    if (parts.length >= 4) {
                        let pctStr = parts[3].replace("%", "");
                        let pct = parseInt(pctStr) / 100.0;
                        global.brightnessVal = pct;
                        global.showBrightnessOsd = true;
                        brightnessOsdTimer.restart();
                    }
                }
            }
        }

        Process {
            id: brightnessMonitor
            command: ["udevadm", "monitor", "--udev", "--subsystem-match=backlight"]
            running: true
            stdout: SplitParser {
                onRead: data => {
                    changeBrightnessProc.running = true;
                }
            }
        }

        // State Machine
        // property int barLevel: 1
        property bool isLocked: false
        property string activePanel: ""
        property bool showVolumeOsd: false
        property bool showBrightnessOsd: false
        property real brightnessVal: 1.0
        property real activeWorkspacesWidth: 84

        function resetTimer() {
            if (barLevel === 2)
                inactivityTimer.restart();
        }

        function setPanel(panelName) {
            resetTimer();
            if (activePanel === panelName) {
                activePanel = "";
                barLevel = 2;
            } else {
                activePanel = panelName;
                level2Width = colomn.implicitWidth + 24;
                barLevel = 3;
                isLocked = true; // interacting locks it
            }
        }

        // color: "transparent"
        //
        // anchors {
        //     top: true
        //     left: true
        //     right: true
        // }
        // margins.top: 4
        // margins.left: 10
        // margins.right: 10

        WlrLayershell.exclusiveZone: 24 // Reduced further, bar will partially overlay maximized windows
        WlrLayershell.layer: WlrLayer.Top // Ensure it renders above windows

        // implicitHeight: island.height

        property real level2Width: 0

        // focusable: global.barLevel > 1

        HyprlandFocusGrab {
            active: global.barLevel > 1
            windows: [global]
            onCleared: {
                global.barLevel = 1;
                global.activePanel = "";
                global.isLocked = false;
            }
        }

        Shortcut {
            sequence: "Escape"
            onActivated: {
                if (global.barLevel === 3) {
                    global.barLevel = 1;
                    global.activePanel = "";
                    global.isLocked = false;
                } else if (global.barLevel === 2) {
                    global.barLevel = 1;
                    global.isLocked = false;
                }
            }
        }

        Timer {
            id: inactivityTimer
            interval: 10000
            running: global.barLevel === 2
            repeat: false
            onTriggered: {
                global.barLevel = 1;
                global.activePanel = "";
                global.isLocked = false;
            }
        }

        Timer {
            id: osdTimer
            interval: 2000
            running: false
            repeat: false
            onTriggered: {
                global.showVolumeOsd = false;
            }
        }

        Timer {
            id: brightnessOsdTimer
            interval: 2000
            running: false
            repeat: false
            onTriggered: {
                global.showBrightnessOsd = false;
            }
        }

        Rectangle {
            // id: island
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: global.barLevel === 3 ? Math.max(colomn.implicitWidth + 24, global.level2Width) : colomn.implicitWidth + 24
            height: colomn.implicitHeight + 16
            radius: 15
            // color: global.bgColor
            clip: true // this one I need to look into

            Behavior on width {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 180
                    easing.type: Easing.OutCubic
                }
            }

            HoverHandler {
                onPointChanged: global.resetTimer()
            }

            TapHandler {
                onTapped: {
                    global.resetTimer();
                    global.isLocked = true;
                    if (global.barLevel === 1) {
                        global.barLevel = 2;
                    }
                }
            }

            Item {
                // id: contentRoot
                // anchors.fill: parent
                // anchors.margins: 8
                // anchors.leftMargin: 12
                // anchors.rightMargin: 12

                ColumnLayout {
                    // id: colomn
                    // anchors.fill: parent
                    // spacing: 6

                    RowLayout {
                        id: row1
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 6

                        ClockPill {
                            opacity: global.barLevel === 2 ? 1.0 : 0.0
                            visible: opacity > 0
                            textFont: global.shellFont
                            fgColor: global.fgColor
                            bgColor: "transparent"
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        Item {
                            id: workspaceOsdContainer
                            implicitWidth: (global.barLevel < 3 && global.showBrightnessOsd) ? brightnessOsd.implicitWidth : ((global.barLevel < 3 && global.showVolumeOsd) ? volumeOsd.implicitWidth : workspacesPill.implicitWidth)
                            implicitHeight: workspacesPill.implicitHeight
                            visible: global.barLevel < 3

                            Workspaces {
                                id: workspacesPill
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: (global.barLevel < 3 && !global.showVolumeOsd && !global.showBrightnessOsd) ? 1.0 : 0.0
                                visible: opacity > 0
                                bgColor: global.bgColor
                                fgColor: global.fgColor
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                onImplicitWidthChanged: {
                                    if (implicitWidth > 0) {
                                        global.activeWorkspacesWidth = implicitWidth;
                                    }
                                }
                            }

                            VolumeOSD {
                                id: volumeOsd
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: (global.barLevel < 3 && global.showVolumeOsd && !global.showBrightnessOsd) ? 1.0 : 0.0
                                visible: opacity > 0
                                fgColor: global.fgColor
                                implicitWidth: global.activeWorkspacesWidth * 1.4
                                implicitHeight: workspacesPill.implicitHeight
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }

                            BrightnessOSD {
                                id: brightnessOsd
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: (global.barLevel < 3 && global.showBrightnessOsd) ? 1.0 : 0.0
                                visible: opacity > 0
                                fgColor: global.fgColor
                                implicitWidth: global.activeWorkspacesWidth * 1.4
                                implicitHeight: workspacesPill.implicitHeight
                                Behavior on opacity {
                                    NumberAnimation {
                                        duration: 120
                                        easing.type: Easing.OutCubic
                                    }
                                }
                            }
                        }

                        Bluetooth {
                            opacity: global.barLevel === 2 ? 1.0 : 0.0
                            visible: opacity > 0
                            textFont: global.shellFont
                            fgColor: global.fgColor
                            bgColor: "transparent"
                            onClicked: global.setPanel("bluetooth")
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        WifiPill {
                            opacity: global.barLevel === 2 ? 1.0 : 0.0
                            visible: opacity > 0
                            textFont: global.shellFont
                            fgColor: global.fgColor
                            bgColor: "transparent"
                            onClicked: global.setPanel("wifi")
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }

                        PowerButton {
                            opacity: global.barLevel === 2 ? 1.0 : 0.0
                            visible: opacity > 0
                            textFont: global.shellFont
                            fgColor: global.fgColor
                            bgColor: "transparent"
                            onClicked: global.setPanel("power")
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: global.barLevel === 3 ? (panelLoader.item ? panelLoader.item.implicitHeight : 0) : (global.barLevel === 2 ? row2.implicitHeight : 0)
                        visible: Layout.preferredHeight > 0

                        Behavior on Layout.preferredHeight {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutCubic
                            }
                        }

                        RowLayout {
                            id: row2
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            opacity: global.barLevel === 2 ? 1.0 : 0.0
                            visible: opacity > 0
                            spacing: 6

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 120
                                    easing.type: Easing.OutCubic
                                }
                            }

                            Battery {
                                textFont: global.shellFont
                                fgColor: global.fgColor
                                bgColor: "transparent"
                                onClicked: global.setPanel("battery")
                            }

                            AudioPill {
                                textFont: global.shellFont
                                fgColor: global.fgColor
                                bgColor: "transparent"
                                onClicked: global.setPanel("audio")
                            }

                            SystemMetrics {
                                textFont: global.shellFont
                                fgColor: global.fgColor
                            }
                        }

                        Loader {
                            id: panelLoader
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: parent.width
                            opacity: global.barLevel === 3 ? 1.0 : 0.0
                            visible: opacity > 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                    easing.type: Easing.OutCubic
                                }
                            }

                            source: {
                                if (global.activePanel === "audio")
                                    return "AudioPanel.qml";
                                if (global.activePanel === "bluetooth")
                                    return "BluetoothPanel.qml";
                                if (global.activePanel === "wifi")
                                    return "WifiPanel.qml";
                                if (global.activePanel === "battery")
                                    return "BatteryPanel.qml";
                                if (global.activePanel === "power")
                                    return "PowerPanel.qml";
                                return "";
                            }
                        }
                    }
                }
            }
        }
    } // end PanelWindow
} // end ShellRoot
