import QtQuick
import QtQuick.Layouts
import qs.templates

// a clickable bar entry: a pill that lights on hover and stays lit while its menu is open,
// using the same fills as the menu rows so the bar and the card read as one surface
Rectangle {
    id: root

    property string menu: ""             // Globals.toggleMenu name; empty -> handle clicked() yourself
    property bool anchorToButton: true   // card opens under this button; false -> the menu's own default spot
    property bool active: false          // bind to the menu's open-state
    default property alias content: row.data
    signal clicked

    implicitWidth: row.implicitWidth + Globals.barItemPadding * 2
    implicitHeight: Globals.barItemHeight
    radius: height / 2
    color: Qt.alpha(Globals.fgColor, active ? 0.11 : mouse.pressed ? 0.1 : mouse.containsMouse ? 0.06 : 0)
    scale: mouse.pressed ? 0.96 : 1

    Behavior on color {
        ColorAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: Globals.barItemPadding + 2 // between readings sharing one pill (cpu + ram)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.menu === "") {
                Globals.dismissPopup();
                root.clicked();
                return;
            }
            Globals.menuAnchorX = root.anchorToButton ? root.mapToItem(null, root.width / 2, 0).x : -1;
            Globals.toggleMenu(root.menu);
        }
    }
}
