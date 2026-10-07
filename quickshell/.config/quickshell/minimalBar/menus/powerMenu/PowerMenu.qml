import Quickshell
import Quickshell.Io
import qs.templates

import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property int selectedIndex: -1
    readonly property string actionScript: Qt.resolvedUrl("power-action.sh").toString().replace(/^file:\/\//, "")

    function handleKey(event): void {
        const k = event.key;
        if (k === Qt.Key_Right || k === Qt.Key_Down || k === Qt.Key_Tab) {
            root.selectedIndex = (root.selectedIndex + 1) % 4;
            event.accepted = true;
        } else if (k === Qt.Key_Left || k === Qt.Key_Up || k === Qt.Key_Backtab) {
            root.selectedIndex = root.selectedIndex < 0 ? 3 : (root.selectedIndex + 3) % 4;
            event.accepted = true;
        } else if (k >= Qt.Key_1 && k <= Qt.Key_4) {
            root.selectedIndex = k - Qt.Key_1;
            event.accepted = true;
        } else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && root.selectedIndex >= 0) {
            [suspend, logout, reboot, poweroff][root.selectedIndex].activate();
            event.accepted = true;
        }
    }

    Connections {
        target: Globals
        function onPowerMenuOpenChanged(): void {
            if (Globals.powerMenuOpen)
                root.selectedIndex = -1;
        }
    }

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
        // always centred under the bar, no matter what opened it (logo click, IPC, power key)
        hAlign: "center"
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: Globals.spacing
        onKeyDown: event => root.handleKey(event)

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
                    text: "󰐥"
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
                    runThis: ["sh", root.actionScript, "suspend"]
                    isActive: root.selectedIndex === 0
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
                    runThis: ["sh", root.actionScript, "logout"]
                    isActive: root.selectedIndex === 1
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
                    runThis: ["sh", root.actionScript, "reboot"]
                    isActive: root.selectedIndex === 2
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
                    runThis: ["sh", root.actionScript, "poweroff"]
                    isActive: root.selectedIndex === 3
                    onClicked: {
                        Globals.powerMenuOpen = false;
                    }
                }
            }
            Text {
                Layout.fillWidth: true
                text: "← → select · Enter: run · Esc: close"
                color: Qt.alpha(Globals.fgColor, 0.45)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 3
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
