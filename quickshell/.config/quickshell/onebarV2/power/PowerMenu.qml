import Quickshell
import Quickshell.Io
import Quickshell.Wayland
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
    PanelWindow { // qmllint disable uncreatable-type
        id: centerWindow

        visible: Globals.powerMenuOpen // watches global state

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        margins {
            top: Globals.marginsTop + Globals.currentBarHeight + Globals.hyprGaps // the margin from the screen top + bars height + WM gaps
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        implicitWidth: container.implicitWidth
        implicitHeight: container.implicitHeight

        color: "transparent"
        exclusionMode: ExclusionMode.Ignore // NB

        // force Wayland to send keyboard events to this window
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            focus: true
            Keys.onPressed: event => {
                Globals.powerMenuOpen = false;
            }
        }

        // this closes the menu the moment you click outside the window
        MouseArea {
            anchors.fill: parent
            onClicked: Globals.powerMenuOpen = false
        }

        Rectangle {
            id: container
            anchors {
                top: parent.top
                topMargin: Globals.currentBarHeight - 26
                horizontalCenter: parent.horizontalCenter // Centers it left-to-right
            }

            implicitHeight: centerCol.implicitHeight + 24
            implicitWidth: centerCol.implicitWidth + 24

            color: Globals.bgColor
            radius: Globals.radius
            border.color: Globals.borderColor
            border.width: Globals.borderWidth

            Layout.fillWidth: parent

            ColumnLayout {
                id: centerCol
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: Globals.margins
                }
                spacing: Globals.spacing
                implicitWidth: buttons.implicitWidth

                // header row
                RowLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Text {
                        text: "  󰐥"
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
}
