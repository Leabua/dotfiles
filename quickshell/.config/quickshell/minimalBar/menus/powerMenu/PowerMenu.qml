pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property int selectedIndex: -1
    readonly property string actionScript: Quickshell.shellDir + "/menus/powerMenu/power-action.sh"
    readonly property var actions: [
        { name: "suspend", label: "Suspend", icon: "suspend" },
        { name: "logout", label: "Log out", icon: "logout" },
        { name: "reboot", label: "Restart", icon: "restart" },
        { name: "poweroff", label: "Power off", icon: "power" }
    ]

    function activateAction(index: int): void {
        if (index < 0 || index >= root.actions.length || actionProc.running)
            return;
        actionProc.command = ["sh", root.actionScript, root.actions[index].name];
        actionProc.running = true;
        Globals.powerMenuOpen = false;
    }

    function handleKey(event): void {
        const k = event.key;
        if (k === Qt.Key_Right || k === Qt.Key_Down || (k === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (root.selectedIndex + 1) % root.actions.length;
            event.accepted = true;
        } else if (k === Qt.Key_Left || k === Qt.Key_Up || k === Qt.Key_Backtab || (k === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = root.selectedIndex < 0 ? root.actions.length - 1 : (root.selectedIndex + root.actions.length - 1) % root.actions.length;
            event.accepted = true;
        } else if (k >= Qt.Key_1 && k <= Qt.Key_4) {
            root.selectedIndex = k - Qt.Key_1;
            event.accepted = true;
        } else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && root.selectedIndex >= 0) {
            root.activateAction(root.selectedIndex);
            event.accepted = true;
        }
    }

    Process { id: actionProc }

    Connections {
        target: Globals
        function onPowerMenuOpenChanged(): void {
            if (Globals.powerMenuOpen)
                root.selectedIndex = -1;
        }
    }

    IpcHandler {
        target: "powerMenu"
        function toggle(): void { Globals.powerMenuOpen = !Globals.powerMenuOpen; }
        function show(): void { Globals.powerMenuOpen = true; }
        function hide(): void { Globals.powerMenuOpen = false; }
    }

    PopupWindow {
        id: popup
        open: Globals.powerMenuOpen
        onDismissed: Globals.powerMenuOpen = false
        onKeyDown: event => root.handleKey(event)
        hAlign: "center"
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: 16
        backgroundColor: Globals.bgColor

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        ColumnLayout {
            width: Math.min(288, popup.availableWidth)
            spacing: 16

            MenuHeader {
                title: "Power"
                icon: "power"
                onCloseRequested: Globals.powerMenuOpen = false
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: root.actions
                    delegate: MenuActionRow {
                        required property var modelData
                        required property int index

                        text: modelData.label
                        icon: modelData.icon
                        selected: root.selectedIndex === index
                        destructive: modelData.name === "poweroff"
                        onHovered: root.selectedIndex = index
                        onClicked: root.activateAction(index)
                    }
                }
            }
        }
    }
}
