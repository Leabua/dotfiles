import QtQuick
import QtQuick.Layouts
import qs.templates

// a clickable bar entry: a pill that lights on hover and stays lit while its menu is open,
// with stronger fills so the small bar entries stay legible against the island
Rectangle {
    id: root

    property string menu: ""             // Globals.toggleMenu name; empty -> handle clicked() yourself
    property bool anchorToButton: true   // card opens under this button; false -> the menu's own default spot
    property bool active: false          // bind to the menu's open-state
    default property alias content: row.data
    signal clicked

    implicitWidth: row.implicitWidth + Globals.barItemPadding * 2
    implicitHeight: Globals.barItemHeight
    radius: Globals.barItemRadius
    color: Qt.alpha(Globals.fgColor, active ? 0.22 : mouse.pressed ? 0.18 : mouse.containsMouse ? 0.12 : 0)
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
