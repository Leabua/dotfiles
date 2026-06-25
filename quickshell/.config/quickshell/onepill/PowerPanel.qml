import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    implicitWidth: Math.max(360, layout.implicitWidth)
    implicitHeight: layout.implicitHeight
    color: "transparent"

    property color fgColor: global.fgColor
    property font textFont: global.shellFont

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "󰐥 Power Menu"
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

        // Lock
        PowerAction {
            icon: "󰌾"
            label: "Lock"
            shellCommand: "hyprlock"
        }

        // Log Out
        PowerAction {
            icon: "󰍃"
            label: "Log Out"
            shellCommand: "hyprlock & sleep 0.5 && hyprctl dispatch exit"
        }

        // Reboot
        PowerAction {
            icon: "󰑓"
            label: "Reboot"
            shellCommand: "systemctl reboot"
        }

        // Power Off
        PowerAction {
            icon: "󰐥"
            label: "Power Off"
            shellCommand: "systemctl poweroff"
        }
        }
    }

    component PowerAction : Rectangle {
        property string icon: ""
        property string label: ""
        property string shellCommand: ""

        implicitWidth: 80
        implicitHeight: 80
        radius: 16
        color: hoverHandler.hovered ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.1) : "transparent"
        

        Behavior on color { ColorAnimation { duration: 150 } }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8
            Text {
                text: icon
                font.family: root.textFont.family
                font.pixelSize: 24
                color: root.fgColor
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: label
                font.family: root.textFont.family
                font.pixelSize: 12
                color: root.fgColor
                Layout.alignment: Qt.AlignHCenter
            }
        }

        HoverHandler { id: hoverHandler; cursorShape: Qt.PointingHandCursor }
        TapHandler {
            onTapped: {
                proc.running = true;
            }
        }
        Process {
            id: proc
            command: ["sh", "-c", shellCommand]
        }
    }
}
