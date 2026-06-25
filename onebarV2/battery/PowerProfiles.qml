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

    // Power Menu Dropdown
    PanelWindow { // qmllint disable uncreatable-type
        id: centerWindow

        visible: Globals.powerProfilesOpen // watches global state

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
                Globals.powerProfilesOpen = false;
            }
        }

        // this closes the menu the moment you click outside the window
        MouseArea {
            anchors.fill: parent
            onClicked: Globals.powerProfilesOpen = false
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
                        text: "  󱐋"
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
                        runThis: ["powerprofilesctl", "set", "power-saver"]
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
                        runThis: ["powerprofilesctl", "set", "balanced"]
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
                        runThis: ["powerprofilesctl", "set", "performance"]
                        isActive: root.activeProfile === "performance"
                        onClicked: {
                            getProfileCmd.running = true;
                        }
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
