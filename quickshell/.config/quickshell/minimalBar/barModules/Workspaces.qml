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
    // dots aren't pills, so they carry the pills' padding themselves to sit on the same inset. On the
    // left they tuck under the clock's padding instead, to look as far from the time as the logo is.
    // Tabular digits carry ~4px of side bearing the solid dots don't, so the dots sit that much further out
    Layout.leftMargin: Globals.barGlyphGap + 4 - Globals.barItemPadding
    Layout.rightMargin: Globals.barItemPadding

    property string screenName: ""

    // defaults -> check Globals.qml
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

            // dots, with the focused workspace stretched into a pill. Switching is keyboard-driven and happens
            // hundreds of times a day, so the stretch is instant on purpose -> no width animation to sit through
            implicitWidth: isActive ? Globals.barIconSize + 12 : Globals.barIconSize
            implicitHeight: Globals.barIconSize
            radius: height / 2

            property color dotColor: {
                if (workspaceLayout.isNiri)
                    return workspaceLayout.screenName.startsWith("eDP") ? workspaceLayout.fgColor : workspaceLayout.fgColor2;
                if (!ws || !ws.monitor)
                    return workspaceLayout.fgColor;
                return ws.monitor.name.startsWith("eDP") ? workspaceLayout.fgColor : workspaceLayout.fgColor2;
            }

            color: isActive ? dotColor : Qt.alpha(dotColor, (ws ? 0.45 : 0.15) + (mouse.containsMouse ? 0.15 : 0))

            MouseArea {
                id: mouse
                anchors.fill: parent
                anchors.margins: -1
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Globals.dismissPopup();
                    if (workspaceLayout.isNiri) {
                        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", rect.workspaceId.toString()]);
                    } else {
                        Hyprland.dispatch("hl.dsp.focus({ workspace = " + rect.workspaceId + " })");
                    }
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: Globals.animFast
                }
            }
        }
    }
}
