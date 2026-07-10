pragma ComponentBehavior: Bound
import Quickshell.Io
import QtQuick
import qs.templates

Item {
    id: root

    property string distroId: ""

    property string icon: {
        const glyphs = {
            "arch": "󰣇",
            "ubuntu": "󰕈",
            "fedora": "󰣛",
            "debian": "󰣚",
            "manjaro": "󱘊",
            "nixos": "󱄅",
            "opensuse-tumbleweed": "󰮤",
            "opensuse-leap": "󰮤",
            "gentoo": "󰣨",
            "endeavouros": "󰣇",
            "pop": "󰣇"
        };
        return glyphs[distroId] ?? "󰻀"; //fallback
    }

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth

    Process {
        id: osProc
        command: ["sh", "-c", ". /etc/os-release && echo $ID"]
        stdout: StdioCollector {
            onStreamFinished: root.distroId = text.trim()
        }
        Component.onCompleted: running = true
    }

    // Might make this the power menu
    BarIcon {
        id: textID
        icon: root.icon
        color: Globals.fgColor

        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            // onClicked: Globals.powerMenuOpen = !Globals.powerMenuOpen
        }
    }
}
