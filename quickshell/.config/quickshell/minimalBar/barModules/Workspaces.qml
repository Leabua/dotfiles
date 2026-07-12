pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import qs.templates

RowLayout {
    id: workspaceLayout
    spacing: Globals.spacing

    //  TODO: set per-instance from shell.qml -> BarRow1.qml (this bar is instantiated
    // once per monitor) -> only used on niri, since niri's workspaces genuinely
    // belong to one output each, unlike Hyprland's shared global numbering

    property string screenName: ""

    // defaults -> check Globals.qml
    property color bgColor: Globals.bgColor
    property color fgColor: Globals.fgColor
    property color fgColor2: Globals.fgColor2

    readonly property bool isNiri: !!Quickshell.env("NIRI_SOCKET")

    // ------- niri -------
    property var niriWorkspaces: []

    readonly property var niriOutputWorkspaces: {
        if (!isNiri)
            return [];
        return niriWorkspaces.filter(w => w.output === screenName).sort((a, b) => a.index - b.index);
    }

    Process {
        running: workspaceLayout.isNiri
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data)
                    return;
                let event;
                try {
                    event = JSON.parse(data);
                } catch (e) {
                    return;
                }

                if (event.WorkspacesChanged) {
                    workspaceLayout.niriWorkspaces = event.WorkspacesChanged.workspaces;
                } else if (event.WorkspaceActivated) {
                    const id = event.WorkspaceActivated.id;
                    const focused = event.WorkspaceActivated.focused;
                    const activatedOutput = workspaceLayout.niriWorkspaces.find(w => w.id === id)?.output;
                    workspaceLayout.niriWorkspaces = workspaceLayout.niriWorkspaces.map(w => Object.assign({}, w, {
                            is_active: w.id === id || (w.output === activatedOutput ? false : w.is_active),
                            is_focused: focused ? w.id === id : (w.is_focused && w.id !== id)
                        }));
                } else if (event.WorkspaceUrgencyChanged) {
                    const id = event.WorkspaceUrgencyChanged.id;
                    const urgent = event.WorkspaceUrgencyChanged.urgent;
                    workspaceLayout.niriWorkspaces = workspaceLayout.niriWorkspaces.map(w => w.id === id ? Object.assign({}, w, {
                            is_urgent: urgent
                        }) : w);
                }
            }
        }
    }

    // ------- Hyprland -------
    readonly property var liveWorkspaceIds: Hyprland.workspaces.values.map(w => w.id).filter(id => id > 0)
    readonly property int maxWorkspaceId: liveWorkspaceIds.length > 0 ? Math.max(...liveWorkspaceIds) : 0

    Repeater {
        model: workspaceLayout.isNiri ? workspaceLayout.niriOutputWorkspaces.length : Math.max(9, workspaceLayout.maxWorkspaceId)

        delegate: Rectangle {
            id: rect
            required property int index

            property var niriWs: workspaceLayout.isNiri ? workspaceLayout.niriOutputWorkspaces[index] : null
            property int workspaceId: workspaceLayout.isNiri ? (niriWs ? niriWs.index : index + 1) : index + 1

            property var ws: workspaceLayout.isNiri ? niriWs : Hyprland.workspaces.values.find(w => w.id === workspaceId)
            property bool isActive: workspaceLayout.isNiri ? !!(niriWs && niriWs.is_active) : Hyprland.focusedWorkspace?.id === (workspaceId)

            // How many dots to show. Niri essentially does last occupied window + 1 and hyprland is my pref for 5 persistant workspaces
            visible: workspaceLayout.isNiri ? true : workspaceId <= Math.max(5, workspaceLayout.maxWorkspaceId)

            // spherical indicators -> a circle is just a square where the radius = 0.5 x height ie make them equal to get a circle
            implicitWidth: isActive ? Globals.textFont.pixelSize + 7 : Globals.textFont.pixelSize // decrease to make more vertical
            implicitHeight: isActive ? Globals.textFont.pixelSize - 4 : Globals.textFont.pixelSize // decrease to make more flat
            radius: implicitHeight / 2

            property color dotColor: {
                if (workspaceLayout.isNiri)
                    return workspaceLayout.screenName.startsWith("eDP") ? workspaceLayout.fgColor : workspaceLayout.fgColor2;
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
