pragma ComponentBehavior: Bound
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.defaults

RowLayout {
    id: workspaceLayout
    spacing: Globals.spacing

    // defaults -> check Globals.qml
    property color bgColor: Globals.bgColor
    property color fgColor: Globals.fgColor
    property color fgColor2: Globals.fgColor2

    // ids of workspaces that actually exist right now (named/special workspaces have negative ids, exclude those)
    readonly property var liveWorkspaceIds: Hyprland.workspaces.values.map(w => w.id).filter(id => id > 0)
    readonly property int maxWorkspaceId: liveWorkspaceIds.length > 0 ? Math.max(...liveWorkspaceIds) : 0

    Repeater {

        model: Math.max(9, workspaceLayout.maxWorkspaceId) // this part is more a thing of not calculating every workspace but I figure that using "model: 10" works too

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

            property color dotColor: {
                if (!ws || !ws.monitor)
                    return workspaceLayout.fgColor;
                return ws.monitor.name.startsWith("eDP") ? workspaceLayout.fgColor : workspaceLayout.fgColor2;
            }

            color: isActive ? dotColor : (ws ? Qt.alpha(dotColor, 0.45) : Qt.alpha(dotColor, 0.15))

            Behavior on color {
                ColorAnimation {
                    duration: 60
                }
            }
        }
    }
}
