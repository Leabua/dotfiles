import Quickshell
import Quickshell.Io
import qs.defaults

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
    // PopupWindow just being the wrapper I use to make a window that floats has the property of click outside to close and keyboard press to close.
    // Prevents repeating a tonne of boilerplate every singe time

    PopupWindow {
        open: Globals.powerMenuOpen
        onDismissed: Globals.powerMenuOpen = false
        hAlign: "center"
        cardTopMargin: Globals.currentBarHeight - 26
        padding: Globals.spacing

        margins {
            top: Globals.marginsTop + Globals.currentBarHeight + Globals.hyprGaps // screen top + bar height + WM gaps
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
                    text: "  󰐥"  // manually pushed it right
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

            // The buttons in the row
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
                    icon: "󰍃"
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
                    icon: "󰜉"
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
                    icon: "󰐥"
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
