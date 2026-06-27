pragma ComponentBehavior: Bound
import Quickshell.Io
import QtQuick
import qs.defaults

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
        return glyphs[distroId] ?? "󰻀"; // generic penguin as fallback
    }

    implicitHeight: textID.implicitHeight - 0.5 // arch logo in particular is always obnoxiously large so shrink as needed
    implicitWidth: textID.implicitWidth - 2

    Process {
        id: osProc
        command: ["sh", "-c", ". /etc/os-release && echo $ID"]
        stdout: StdioCollector {
            onStreamFinished: root.distroId = text.trim()
        }
        Component.onCompleted: running = true
    }

    Text {
        id: textID
        text: root.icon
        font.family: Globals.textFont.family
        font.pixelSize: Globals.barIconSize
        color: Globals.fgColor
    }
}
