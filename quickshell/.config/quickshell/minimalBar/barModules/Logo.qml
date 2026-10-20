pragma ComponentBehavior: Bound
import Quickshell.Io
import QtQuick
import qs.templates

// distro mark -> opens the power menu (centred, so not anchored to this button)
BarButton {
    id: root

    property string distroId: ""
    readonly property var glyphs: ({
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
        })

    menu: "powerMenu"
    anchorToButton: false
    active: Globals.powerMenuOpen
    iconOnly: true

    BarValue {
        id: value

        // a brand mark stays a font glyph rather than a redrawn line icon
        Text {
            anchors.centerIn: parent
            text: root.glyphs[root.distroId] ?? "󰻀"
            color: value.iconColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.barIconSize
        }
    }

    Process {
        command: ["sh", "-c", ". /etc/os-release && echo $ID"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.distroId = text.trim()
        }
    }
}
