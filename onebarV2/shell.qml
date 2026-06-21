import Quickshell
import QtQuick
import QtQuick.Layouts // need for rowlayout and colomnLayout
import qs // home for colours, font etc
import qs.battery
import qs.sysUtils

// import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow { // used for bars panels and overlays
            id: shell
            property var modelData
            screen: modelData
            color: "transparent" // this is to make the main bar transparent
            // makes bar go to top
            anchors {
                top: true
                left: true
                right: true
            }

            // makes it float instead of touching anything
            margins {
                top: 6
                left: 10
                right: 10
                bottom: -3
            }

            // WlrLayershell.exclusiveZone: 24 // Reduced further, bar will partially overlay maximized windows
            // WlrLayershell.layer: WlrLayer.Top // Ensure it renders above windows

            implicitHeight: Math.max(12, island.implicitHeight)

            // States of the bar -> level 1 to 3
            property int barLevel: 1
            property bool isLocked: false

            // get Hyprland to focus on the bar if its in level 2
            focusable: shell.barLevel > 1

            Rectangle {
                id: island
                anchors.centerIn: parent
                radius: height / 2
                color: Globals.bgColor
                implicitHeight: contentRoot.implicitHeight + 10
                implicitWidth: contentRoot.implicitWidth + 14

                Item {
                    id: contentRoot
                    anchors.centerIn: parent
                    implicitHeight: colomn.implicitHeight
                    implicitWidth: colomn.implicitWidth
                    ColumnLayout {
                        id: colomn
                        anchors.centerIn: parent
                        spacing: 6
                        RowLayout {
                            id: row1
                            spacing: 6
                            Clock {}
                            Workspaces {}
                            BatteryIcons {}
                            CPU {}
                            Memory {}
                        }
                    }
                }
            }
        }
    }
}
