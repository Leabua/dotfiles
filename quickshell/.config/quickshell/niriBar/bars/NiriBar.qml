import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.barModules

// one rail per output, floating against the left edge and centred top to bottom:
// clock -> workspaces -> alerts -> wifi + system -> power (the cookie at the foot)
PanelWindow { // qmllint disable uncreatable-type
    id: bar

    property var modelData
    screen: modelData
    color: "transparent"
    WlrLayershell.namespace: "niribar-rail"

    visible: Globals.barShown

    anchors {
        top: true
        bottom: true
        left: true
    }

    // no top / bottom margin -> scene y is screen y, which the menus use to open level with their trigger.
    // the slightly negative right margin lets tiled windows sit a hair closer than rail + margin
    margins {
        left: Globals.railEdgeMargin
        right: Globals.marginsBottom
    }
    implicitWidth: Globals.railWidth

    // empty space beside the rail dismisses the open menu
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Globals.dismissPopup()
    }

    BarIsland {
        anchors.centerIn: parent

        Clock {}
        Workspaces {
            screenName: bar.modelData.name
        }
        CriticalAlerts {}

        // super + alt + space folds these away
        ColumnLayout {
            visible: Globals.rightIslandShown
            spacing: Globals.railGap
            Layout.alignment: Qt.AlignHCenter

            Wifi {}
            SystemStatus {}
        }

        Logo {
            Layout.topMargin: 2
        }
    }
}
