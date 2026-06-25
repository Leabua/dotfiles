import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Rectangle {
    id: root

    implicitWidth: 360
    implicitHeight: layout.implicitHeight
    color: "transparent"

    property string currentProfile: "balanced"

    function refresh() {
        if (!getProfileProc.running) getProfileProc.running = true;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Process {
        id: getProfileProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: root.currentProfile = text.trim()
        }
    }

    Process {
        id: setProfileProc
        property string profile: ""
        command: ["powerprofilesctl", "set", profile]
        onRunningChanged: {
            if (!running) {
                root.refresh();
                notifyProc.profileName = profile === "power-saver" ? "Efficient" : (profile === "performance" ? "Performance" : "Balanced");
                notifyProc.icon = profile === "power-saver" ? "󰾆" : (profile === "performance" ? "󰓅" : "󰾅");
                notifyProc.running = true;
            }
        }
    }

    Process {
        id: notifyProc
        property string profileName: ""
        property string icon: ""
        command: ["notify-send", "-h", "string:x-canonical-private-synchronous:power", "Power Profile", icon + "  Switched to " + profileName]
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 10

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "󰓅 Power Profile"
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
                text: "󰾆"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: root.currentProfile === "power-saver" ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: {
                        setProfileProc.profile = "power-saver";
                        setProfileProc.running = true;
                    }
                }
            }

            Text {
                text: "󰾅"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: root.currentProfile === "balanced" ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: {
                        setProfileProc.profile = "balanced";
                        setProfileProc.running = true;
                    }
                }
            }

            Text {
                text: "󰓅"
                font.family: global.shellFont.family
                font.pixelSize: 24
                color: root.currentProfile === "performance" ? global.fgColor : Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.4)
                
                TapHandler {
                    onTapped: {
                        setProfileProc.profile = "performance";
                        setProfileProc.running = true;
                    }
                }
            }
        }
    }
}
