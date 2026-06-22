pragma ComponentBehavior: Bound
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs

RowLayout {
    id: workspaceLayout
    spacing: 6

    // defaults -> check Globals
    property color bgColor: Globals.bgColor
    property color fgColor: Globals.fgColor
    property color fgColor2: Globals.fgColor2

    // ids of workspaces that actually exist right now (named/special workspaces have negative ids, exclude those)
    property var liveWorkspaceIds: Hyprland.workspaces.values.map(w => w.id).filter(id => id > 0)
    property int maxWorkspaceId: liveWorkspaceIds.length > 0 ? Math.max(...liveWorkspaceIds) : 0

    Repeater {
        // make sure we always have enough delegates, even if workspaces go past 9
        // this part is more a thing of not calculating every workspace but I figure that using "model: 10" works too
        model: Math.max(9, workspaceLayout.maxWorkspaceId)

        delegate: Rectangle {
            id: rect
            required property int index
            property int workspaceId: index + 1

            property var ws: Hyprland.workspaces.values.find(w => w.id === workspaceId)
            property bool isActive: Hyprland.focusedWorkspace?.id === (workspaceId)

            visible: workspaceId <= Math.max(5, workspaceLayout.maxWorkspaceId)

            // perfectCircle
            implicitWidth: Globals.textFont.pixelSize // decrease to make more vertical
            implicitHeight: Globals.textFont.pixelSize // decrease to make more flat
            radius: implicitHeight / 2

            // have different colours depending on which monitor workspace is loaded on
            property color dotColor: {
                if (!ws || !ws.monitor)
                    return workspaceLayout.fgColor;
                return ws.monitor.name.startsWith("eDP") ? workspaceLayout.fgColor : workspaceLayout.fgColor2;
            }

            color: isActive ? dotColor : (ws ? Qt.alpha(dotColor, 0.45) : Qt.alpha(dotColor, 0.15))

            // MouseArea {
            //     anchors.fill: parent
            //     anchors.margins: -1 // increase clickable area a tiny bit over the circles
            //     cursorShape: Qt.PointingHandCursor // change pointer to pointer finger
            //     onClicked: {
            //         if (Hyprland.usingLua) // fallback incase on a system using hyprland without lua so I dont have that issue from waybar where my bar refuses to click
            //             Hyprland.dispatch(`hl.dsp.focus({ workspace = ${rect.workspaceId} })`);
            //         else
            //             Hyprland.dispatch("workspace " + rect.workspaceId);
            //     }
            // }
            Behavior on color {
                ColorAnimation {
                    duration: 60
                }
            }
        }
    }
}
