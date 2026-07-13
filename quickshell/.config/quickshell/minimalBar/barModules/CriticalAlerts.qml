import QtQuick
import QtQuick.Layouts
import qs.templates

// ----- critical metrics surfaced in the centre island while the right cluster is hidden -----
RowLayout {
    id: root
    spacing: Globals.spacing

    readonly property bool cpuAlert: Globals.cpuUsage > 70
    readonly property bool memAlert: Globals.memUsage > 70
    readonly property bool batteryAlert: Globals.batteryReady && ((Globals.batteryPercent <= 20 && !Globals.batteryCharging) || (Globals.batteryPercent >= 80 && Globals.batteryCharging))

    // an empty RowLayout still reserves a spacing gap next to its neighbours -> only take up space when there's something to show
    visible: !Globals.rightIslandShown && (cpuAlert || memAlert || batteryAlert)

    // ~~~ these icons sit mid-screen, so drop the button anchor (-1) -> PopupWindow falls back to its
    //     hAlign ("center") instead of snapping the card to the right edge like the right island does ~~~
    function openCentred(menu: string): void {
        Globals.menuAnchorX = -1;
        Globals.toggleMenu(menu);
    }

    // ~~~ cpu -> engine room ~~~
    Item {
        visible: root.cpuAlert
        implicitWidth: cpuIcon.implicitWidth
        implicitHeight: cpuIcon.implicitHeight

        BarIcon {
            id: cpuIcon
            icon: String.fromCodePoint(0xF2DB)
            displayText: Globals.cpuUsage + "%"
            color: Globals.cpuUsage > 85 ? Globals.criticalColor : Globals.warningColor
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openCentred("engineRoom")
        }
    }

    // ~~~ ram -> engine room ~~~
    Item {
        visible: root.memAlert
        implicitWidth: memIcon.implicitWidth
        implicitHeight: memIcon.implicitHeight

        BarIcon {
            id: memIcon
            icon: "󰘚"
            displayText: Globals.memUsage + "%"
            color: Globals.memUsage > 85 ? Globals.criticalColor : Globals.warningColor
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openCentred("engineRoom")
        }
    }

    // ~~~ battery -> power profiles: low / critical while draining, or topped up while charging ~~~
    Item {
        visible: root.batteryAlert
        implicitWidth: batteryIcon.implicitWidth
        implicitHeight: batteryIcon.implicitHeight

        BarIcon {
            id: batteryIcon
            icon: Globals.batteryCharging ? "󰂅" : (Globals.batteryPercent <= 10 ? "󰁺" : "󰁻")
            displayText: Globals.batteryPercent + "%"
            color: (Globals.batteryPercent <= 10 && !Globals.batteryCharging) ? Globals.criticalColor : (Globals.batteryPercent <= 20 && !Globals.batteryCharging) ? Globals.warningColor : Globals.healthy
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor
            onClicked: root.openCentred("powerProfiles")
        }
    }
}
