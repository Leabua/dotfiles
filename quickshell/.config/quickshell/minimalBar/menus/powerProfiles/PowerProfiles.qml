pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property string activeProfile: ""
    property string errorText: ""
    property int selectedIndex: -1
    readonly property var profiles: [
        { name: "power-saver", label: "Power saver", icon: "leaf" },
        { name: "balanced", label: "Balanced", icon: "balanced" },
        { name: "performance", label: "Performance", icon: "bolt" }
    ]

    function activateProfile(index: int): void {
        if (index < 0 || index >= root.profiles.length || setProfileCmd.running)
            return;
        const profile = root.profiles[index].name;
        if (profile === root.activeProfile)
            return;
        root.errorText = "";
        setProfileCmd.command = ["powerprofilesctl", "set", profile];
        setProfileCmd.running = true;
    }

    function handleKey(event): void {
        const k = event.key;
        const base = root.selectedIndex < 0 ? Math.max(0, root.profiles.findIndex(profile => profile.name === root.activeProfile)) : root.selectedIndex;
        if (k === Qt.Key_Down || k === Qt.Key_Right || (k === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (base + 1) % root.profiles.length;
            event.accepted = true;
        } else if (k === Qt.Key_Up || k === Qt.Key_Left || k === Qt.Key_Backtab || (k === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.selectedIndex = (base + root.profiles.length - 1) % root.profiles.length;
            event.accepted = true;
        } else if (k >= Qt.Key_1 && k <= Qt.Key_3) {
            root.selectedIndex = k - Qt.Key_1;
            event.accepted = true;
        } else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && root.selectedIndex >= 0) {
            root.activateProfile(root.selectedIndex);
            event.accepted = true;
        }
    }

    IpcHandler {
        target: "powerProfiles"
        function toggle(): void { Globals.powerProfilesOpen = !Globals.powerProfilesOpen; }
        function show(): void { Globals.powerProfilesOpen = true; }
        function hide(): void { Globals.powerProfilesOpen = false; }
    }

    Connections {
        target: Globals
        function onPowerProfilesOpenChanged(): void {
            if (Globals.powerProfilesOpen) {
                root.selectedIndex = -1;
                root.errorText = "";
            }
        }
    }

    Process {
        id: getProfileCmd
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: root.activeProfile = text.trim()
        }
        onExited: exitCode => {
            if (exitCode !== 0)
                root.errorText = "Could not read the current power profile";
        }
    }

    Process {
        id: setProfileCmd
        onExited: exitCode => {
            if (exitCode === 0)
                getProfileCmd.running = true;
            else
                root.errorText = "Could not change the power profile";
        }
    }

    Timer {
        interval: 2000
        running: Globals.powerProfilesOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: getProfileCmd.running = true
    }

    PopupWindow {
        id: popup
        open: Globals.powerProfilesOpen
        onDismissed: Globals.powerProfilesOpen = false
        onKeyDown: event => root.handleKey(event)
        hAlign: "center"
        anchorCenterX: Globals.menuAnchorX
        cardTopMargin: Globals.barShown ? Globals.currentBarHeight - Globals.cardY : 0
        padding: 16
        backgroundColor: Globals.bgColor

        margins {
            top: Globals.marginsTop + (Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
            left: Globals.marginsLeft
        }

        ColumnLayout {
            width: Math.min(320, popup.availableWidth)
            spacing: 16

            MenuHeader {
                title: "Power profiles"
                icon: "bolt"
                onCloseRequested: Globals.powerProfilesOpen = false
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Repeater {
                    model: root.profiles
                    delegate: MenuActionRow {
                        required property var modelData
                        required property int index

                        text: modelData.label
                        icon: modelData.icon
                        active: root.activeProfile === modelData.name
                        selected: root.selectedIndex === index
                        enabled: !setProfileCmd.running
                        onHovered: root.selectedIndex = index
                        onClicked: root.activateProfile(index)
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                Layout.leftMargin: 10
                visible: root.errorText !== ""
                text: root.errorText
                wrapMode: Text.WordWrap
                color: Globals.criticalColor
                font.family: Globals.textFont.family
                font.pixelSize: 13
            }
        }
    }
}
