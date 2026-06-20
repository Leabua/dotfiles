import Quickshell
import QtQuick
import qs.styling // personal lib with
import QtQuick.Layouts // need for rowlayout and colomnLayout
import Quickshell.Hyprland

ShellRoot {
    PanelWindow { // used for bars panels and overlays
        id: global
        // this is what the colors for background and text are -> matugen generated & can be expanded
        property color bgColor: "#1e1e1e"
        property color fgColor: Colors.primary

        //default font and font size global
        property font shellFont: Qt.font({
            family: "SF Pro Display",
            letterSpacing: 1,
            pixelSize: 14,
            weight: 600
        })

        color: "transparent" // this is to make the main bar transparent

        // makes bar go to top
        anchors {
            top: true
            left: true
            right: true
        }

        // makes it float instead of touching anything
        margins.top: 6
        margins.left: 10
        margins.right: 10

        // WlrLayershell.exclusiveZone: 24 // Reduced further, bar will partially overlay maximized windows
        // WlrLayershell.layer: WlrLayer.Top // Ensure it renders above windows

        implicitHeight: Math.max(12, island.implicitHeight)

        // States of the bar -> level 1 to 3
        property int barLevel: 1
        property bool isLocked: false

        // get Hyprland to focus on the bar if its in level 2
        focusable: global.barLevel > 1

        Rectangle {
            id: island
            anchors.centerIn: parent
            radius: height / 2
            color: global.bgColor
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
                        Clock {
                            fgColor: global.fgColor
                            textFont: global.shellFont
                        }
                        Workspaces {
                            fgColor: global.fgColor
                        }
                    }
                }
            }
        }
    }
}
