pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.menus.powerMenu
import qs.templates
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property int selectedIndex: -1
    readonly property string actionScript: Quickshell.shellDir + "/menus/powerMenu/power-action.sh"
    // everything but suspend ends the session -> those take a press-and-hold from the pointer
    readonly property var actions: [
        { name: "suspend", label: "Suspend", icon: "suspend", hold: false, verb: "" },
        { name: "logout", label: "Log out", icon: "logout", hold: true, verb: "log out" },
        { name: "reboot", label: "Restart", icon: "restart", hold: true, verb: "restart" },
        { name: "poweroff", label: "Power off", icon: "power", hold: true, verb: "power off" }
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
            if (Globals.powerMenuOpen) {
                root.selectedIndex = -1;
                for (let i = 0; i < tiles.count; i++)
                    tiles.itemAt(i).reset();
            }
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
        anchorCenterX: Globals.menuAnchorX // beside the cookie that toggled it
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: 16
        backgroundColor: Globals.bgColor

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        ColumnLayout {
            width: Math.min(304, popup.availableWidth)
            spacing: 16

            MenuHeader {
                title: "Power"
                icon: "power"
                onCloseRequested: Globals.powerMenuOpen = false
            }

            GridLayout {
                id: grid
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                Repeater {
                    id: tiles
                    model: root.actions
                    delegate: PowerTile {
                        required property var modelData
                        required property int index

                        label: modelData.label
                        icon: modelData.icon
                        hold: modelData.hold
                        danger: modelData.name === "poweroff"
                        selected: root.selectedIndex === index
                        onHovered: root.selectedIndex = index
                        onActivated: root.activateAction(index)
                    }
                }
            }

            // says what the hovered tile needs; keeps its line so the card never jumps
            Text {
                readonly property var action: root.selectedIndex >= 0 ? root.actions[root.selectedIndex] : null
                Layout.fillWidth: true
                Layout.leftMargin: 4
                text: action ? (action.hold ? "Hold to " + action.verb + ", or press Enter" : "Click or press Enter to suspend") : "Pick an action, or press 1 to 4"
                color: Globals.surfaceVariantContent
                font: Globals.bodySmall
                elide: Text.ElideRight
            }
        }
    }
}
