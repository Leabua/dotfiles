import Quickshell
import QtQuick
import QtQuick.Layouts // need for rowlayout and colomnLayout
import qs // home for colours, font etc
import qs.battery
import qs.sysUtils
import Quickshell.Services.UPower

// import Quickshell.Hyprland

Scope {
    Variants {
        model: Quickshell.screens
        // used for bars panels and overlays
        PanelWindow { // qmllint disable uncreatable-type
            id: shell

            // in charge of making a new bar on any connected screen
            property var modelData
            screen: modelData
            //

            color: "transparent" // this is to make the main bar transparent
            // makes bar go to top
            anchors {
                top: true
                left: true
                right: true
            }

            // makes it float instead of touching anything
            margins { // qmllint disable unresolved-type
                top: 6
                left: 10
                right: 10
                bottom: -3
            }

            // WlrLayershell.exclusiveZone: 24 // Reduced further, bar will partially overlay maximized windows
            // WlrLayershell.layer: WlrLayer.Top // Ensure it renders above windows

            // Default States of the bar -> level 1 to 3
            property int barLevel: 1
            property bool isLocked: false

            // get Hyprland to focus on the bar if its in level 2
            focusable: shell.barLevel > 1

            // need this since quickshell bar with no Height defaults to 0 and looks like it dissappears
            implicitHeight: Math.max(12, island.implicitHeight)
            // simple state engine will go here we basically just want to have a spring effect with no bounce that is purely just going to resize based on island.implicitHeight and implicitWidth

            Rectangle {
                id: island
                color: Globals.bgColor // literally the only time we need a bg in the main bar
                anchors.centerIn: parent
                radius: height / 2
                implicitHeight: contentRoot.implicitHeight + 10 // basically padding of the rectangle from bar elements
                implicitWidth: contentRoot.implicitWidth + 14

                Item {
                    id: contentRoot
                    anchors.centerIn: parent
                    // consider making this assignable to a bind so that we can dyanmically hide the bar with something like Super + shift + Space
                    implicitHeight: colomn.implicitHeight
                    implicitWidth: colomn.implicitWidth
                    ColumnLayout {
                        id: colomn
                        anchors.centerIn: parent
                        spacing: 6
                        RowLayout {
                            id: row1
                            spacing: 6
                            // Use shown: false to have it gone forever and true to always have it there
                            Reveal {
                                shown: false
                                Logo {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 2
                                Clock {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 1
                                Workspaces {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 2
                                Memory {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 2
                                Network {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 3
                                CPU {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 3
                                Volume {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 3
                                BatteryIcons {}
                            }
                            Reveal {
                                shown: shell.barLevel >= 3
                                PowerButton {}
                            }
                        }
                    }
                }

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.OutCubic
                    }
                }
                MouseArea {
                    anchors.fill: island
                    anchors.margins: -1 // increase the clickable area a tiny bit over the visible bar
                    cursorShape: Qt.PointingHandCursor // change pointer to pointer finger
                    z: -1 // keep it behind the workspace-dot MouseAreas so clicking a dot still focuses that workspace if workspace clicking is on
                    onClicked: shell.barLevel = shell.barLevel >= 3 ? 1 : shell.barLevel + 1
                }
            }
        }
    }
}
