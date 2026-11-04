import QtQuick
import QtQuick.Layouts
import qs.templates

// a rail item: an M3 state-layer pill. While its menu is open a secondary-container indicator grows out
// from the centre behind it (the M3 rail's active indicator) and the content flips to on-secondary-container
Item {
    id: root

    property string menu: ""           // Globals.toggleMenu name; empty -> handle clicked() yourself
    property bool active: false        // bind to the menu's open-state
    default property alias content: column.data
    signal clicked

    // the colour content inside should take -> BarValue reads it off its host
    readonly property color contentColor: active ? Globals.secondaryContainerContent : Globals.surfaceVariantContent

    implicitWidth: Globals.railItemWidth
    implicitHeight: Math.max(Globals.railItemHeight, column.implicitHeight + 14)
    Layout.alignment: Qt.AlignHCenter

    // press -> a small, quick squeeze so the rail feels like it heard the click
    scale: mouse.pressed ? 0.92 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }

    // active indicator: grows sideways from a sliver to full width with a light overshoot
    Rectangle {
        anchors.centerIn: parent
        height: parent.height
        width: root.active ? parent.width : parent.width * 0.4
        radius: Math.min(width, height) / 2
        color: Globals.secondaryContainer
        opacity: root.active ? 1 : 0
        Behavior on width {
            NumberAnimation {
                duration: Globals.animEnter
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeSpatial
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animFast
            }
        }
    }

    // state layer -> hover / press tint in the content colour
    Rectangle {
        anchors.fill: parent
        radius: Math.min(width, height) / 2
        color: root.contentColor
        opacity: mouse.pressed ? Globals.statePressed : mouse.containsMouse ? Globals.stateHover : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animFast
            }
        }
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: 2
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
            // the card opens beside this item -> remember where it is
            const c = root.mapToItem(null, root.width / 2, root.height / 2);
            Globals.menuAnchorX = c.x;
            Globals.toggleMenu(root.menu);
        }
    }
}
