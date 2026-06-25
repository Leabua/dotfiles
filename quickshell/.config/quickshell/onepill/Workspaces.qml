pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: workspaceLayout
    spacing: 6

    property color bgColor: "#1e1e1e"
    property color fgColor: "#FFFFFF"

    Repeater {
        // ten possible workspaces so repeat this ten times
        model: 10

        // assign a rectangle for each
        delegate: Rectangle {
            required property int index
            property int workspaceId: index + 1

            property var workspaceData: Hyprland.workspaces.values.find(w => w.id === workspaceId)
            property bool isActive: Hyprland.focusedWorkspace != null && Hyprland.focusedWorkspace.id === workspaceId
            property bool isOccupied: workspaceData !== undefined && !isActive // this took forever to figure out

            visible: workspaceId <= 5 || isOccupied || isActive

            implicitWidth: 12
            implicitHeight: 12
            radius: 6

            color: {
                if (isActive) {
                    return workspaceLayout.fgColor;
                }
                if (isOccupied) {
                    return Qt.alpha(workspaceLayout.fgColor, 0.45);
                }
                return Qt.alpha(workspaceLayout.fgColor, 0.10);
            }

            Behavior on color {
                ColorAnimation {
                    duration: 60
                }
            }

            TapHandler {
                onTapped: Hyprland.dispatch("workspace " + workspaceId)
            }
        }
    }
}
