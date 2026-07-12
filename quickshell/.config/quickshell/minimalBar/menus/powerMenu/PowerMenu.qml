import Quickshell
import Quickshell.Io
import qs.templates

import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property bool menuOpen: false

    IpcHandler {
        target: "powerMenu"
        function toggle(): void {
            Globals.powerMenuOpen = !Globals.powerMenuOpen;
        }
        function show(): void {
            Globals.powerMenuOpen = true;
        }
        function hide(): void {
            Globals.powerMenuOpen = false;
        }
    }

    // Power Menu Dropdown

    PopupWindow {
        open: Globals.powerMenuOpen
        onDismissed: Globals.powerMenuOpen = false
        hAlign: "center"
        anchorCenterX: Globals.menuAnchorX
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: Globals.spacing

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0) // below the bar when shown, screen top when hidden
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        ColumnLayout {
            id: centerCol
            spacing: Globals.spacing
            implicitWidth: buttons.implicitWidth

            // header row
            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Text {
                    text: " 󰐥"  // manually pushed it right
                    visible: Globals.headerIcons
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 6
                    font.weight: Globals.textFont.weight
                }
                Text {
                    Layout.fillWidth: true
                    text: "Power Menu"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }
            }

            MenuDivider {}
            // The buttons in the row -> TODO squish these buttons a bit feel too bloated on most screens
            RowLayout {
                id: buttons
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Globals.spacing
                readonly property int largestButton: Math.max(suspend.contentWidth, logout.contentWidth, reboot.contentWidth, poweroff.contentWidth) + Globals.padding

                // suspend
                CenterTextBtn {
                    id: suspend
                    icon: "󰒲"
                    label: "Suspend"
                    largestButton: buttons.largestButton
                    runThis: ["bash", "-c", "hyprlock & sleep 0.5 && systemctl suspend"]
                    onClicked: {
                        Globals.powerMenuOpen = false;
                    }
                }

                // logout
                CenterTextBtn {
                    id: logout
                    icon: String.fromCodePoint(0xF0343)
                    label: "Log Out"
                    largestButton: buttons.largestButton
                    runThis: ["bash", "-c", "if command -v hyprshutdown >/dev/null 2>&1 && [[ \"$XDG_CURRENT_DESKTOP\" == \"Hyprland\" ]]; then hyprshutdown; elif [[ \"$XDG_CURRENT_DESKTOP\" == \"Hyprland\" ]]; then hyprctl dispatch exit; else niri msg action quit; fi"]
                    onClicked: {
                        Globals.powerMenuOpen = false;
                    }
                }

                // reboot
                CenterTextBtn {
                    id: reboot
                    icon: String.fromCodePoint(0xF0E2)
                    label: "Reboot"
                    largestButton: buttons.largestButton
                    runThis: ["systemctl", "reboot"]
                    onClicked: {
                        Globals.powerMenuOpen = false;
                    }
                }

                // shut down
                CenterTextBtn {
                    id: poweroff
                    icon: String.fromCodePoint(0xF011)
                    label: "Power Off"
                    largestButton: buttons.largestButton
                    runThis: ["systemctl", "poweroff"]
                    onClicked: {
                        Globals.powerMenuOpen = false;
                    }
                }
            }
        }
    }
}
