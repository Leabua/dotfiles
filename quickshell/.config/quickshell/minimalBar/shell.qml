import Quickshell
import QtQuick
import qs.templates
import qs.barModules

ShellRoot {
    Variants {
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            property var modelData
            screen: modelData
            color: "transparent"

            //make go top
            anchors {
                top: true
                left: true
                right: true
            }

            /// give some padding
            margins {
                top: Globals.marginsTop
                left: Globals.marginsLeft
                right: Globals.marginsRight
                bottom: Globals.marginsBottom
            }
            implicitHeight: defHeight.implicitHeight + Globals.vertPadding

            Text {
                id: defHeight
                visible: false // purpose is to make a consistent height for the bar so that I never have to deal with jitter
                text: " NEVER SHOW THIS"
                font: Globals.textFont
            }

            //literally some rectangles with positions -> refer to the actual files for whats going on in these rectangles
            BarLeft {
                id: leftIsland
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            BarMiddle {
                anchors.centerIn: parent
            }

            BarRight {
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
