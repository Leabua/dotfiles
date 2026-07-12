import Quickshell
import Quickshell.Io
import qs.templates

import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property bool menuOpen: false

    IpcHandler {
        target: "powerProfiles"
        function toggle(): void {
            Globals.powerProfilesOpen = !Globals.powerProfilesOpen;
        }
        function show(): void {
            Globals.powerProfilesOpen = true;
        }
        function hide(): void {
            Globals.powerProfilesOpen = false;
        }
    }

    // Power Profiles Dropdown
    PopupWindow {
        open: Globals.powerProfilesOpen
        onDismissed: Globals.powerProfilesOpen = false
        hAlign: "center"
        anchorCenterX: Globals.menuAnchorX // open under the bar button that toggled it

        // sit just below the bar when it's shown, shift up to the top when it's hidden
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
                    text: " 󱐋"
                    visible: Globals.headerIcons
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 6
                    font.weight: Globals.textFont.weight
                }
                Text {
                    Layout.fillWidth: true
                    text: "Power Profiles"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }
            }

            MenuDivider {}

            // The buttons in the row
            RowLayout {
                id: buttons
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: Globals.spacing
                readonly property int largestButton: Math.max(efficient.contentWidth, balanced.contentWidth, performance.contentWidth) + Globals.padding

                // efficient
                CenterTextBtn {
                    id: efficient
                    icon: "󰾆"
                    label: "Efficient"
                    largestButton: buttons.largestButton
                    runThis: ["bash", "-c", "powerprofilesctl set power-saver && notify-send -a 'Power Profile' 'Power Profile' 'Efficient'"]
                    isActive: root.activeProfile === "power-saver"
                    onClicked: {
                        getProfileCmd.running = true;
                    }
                }

                // balanced
                CenterTextBtn {
                    id: balanced
                    icon: "󰾅"
                    label: "Balanced"
                    largestButton: buttons.largestButton
                    runThis: ["bash", "-c", "powerprofilesctl set balanced && notify-send -a 'Power Profile' 'Power Profile' 'Balanced'"]
                    isActive: root.activeProfile === "balanced"
                    onClicked: {
                        getProfileCmd.running = true;
                    }
                }

                // performance
                CenterTextBtn {
                    id: performance
                    icon: "󰓅"
                    label: "Performance"
                    largestButton: buttons.largestButton
                    runThis: ["bash", "-c", "powerprofilesctl set performance && notify-send -a 'Power Profile' 'Power Profile' 'Performance'"]
                    isActive: root.activeProfile === "performance"
                    onClicked: {
                        getProfileCmd.running = true;
                    }
                }
            }
        }
    }

    property string activeProfile: "balanced"

    Process {
        id: getProfileCmd
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.activeProfile = text.trim();
            }
        }
    }

    Timer {
        interval: 2000
        running: Globals.powerProfilesOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: getProfileCmd.running = true
    }
}
