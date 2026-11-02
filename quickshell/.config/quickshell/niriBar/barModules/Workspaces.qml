pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import qs.templates

// this output's niri workspaces, top to bottom: dots, with the active one stretched into a tall primary pill.
// Switching is keyboard-driven and happens hundreds of times a day, so the stretch is instant on purpose
ColumnLayout {
    id: root

    property string screenName: ""
    property var workspaces: []

    readonly property var outputWorkspaces: workspaces.filter(w => w.output === root.screenName).sort((a, b) => a.idx - b.idx)
    // the laptop panel reads in primary, any other output in tertiary -> you can tell which screen a column belongs to
    readonly property color accent: screenName.startsWith("eDP") ? Globals.primary : Globals.tertiary

    spacing: 0
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 4
    Layout.bottomMargin: 4

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
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
                    root.workspaces = event.WorkspacesChanged.workspaces;
                } else if (event.WorkspaceActivated) {
                    const id = event.WorkspaceActivated.id;
                    const focused = event.WorkspaceActivated.focused;
                    const output = root.workspaces.find(w => w.id === id)?.output;
                    root.workspaces = root.workspaces.map(w => Object.assign({}, w, {
                            is_active: w.id === id || (w.output === output ? false : w.is_active),
                            is_focused: focused ? w.id === id : (w.is_focused && w.id !== id)
                        }));
                } else if (event.WorkspaceUrgencyChanged) {
                    const id = event.WorkspaceUrgencyChanged.id;
                    root.workspaces = root.workspaces.map(w => w.id === id ? Object.assign({}, w, {
                            is_urgent: event.WorkspaceUrgencyChanged.urgent
                        }) : w);
                }
            }
        }
    }

    Repeater {
        model: root.outputWorkspaces

        delegate: Item {
            id: cell
            required property var modelData

            readonly property bool isActive: modelData.is_active
            readonly property bool isUrgent: !!modelData.is_urgent
            // niri keeps one empty workspace below the last used one; an occupied one has a focused window
            readonly property bool occupied: modelData.active_window_id !== null && modelData.active_window_id !== undefined

            // the hit area is the full rail item width, so the small dots are easy to click
            implicitWidth: Globals.railItemWidth
            implicitHeight: dot.height + 8
            Layout.alignment: Qt.AlignHCenter

            Rectangle {
                id: dot
                anchors.centerIn: parent
                width: Globals.workspaceDot
                height: cell.isActive ? Globals.workspaceDot * 2.6 : Globals.workspaceDot
                radius: width / 2
                color: {
                    if (cell.isUrgent)
                        return Globals.error;
                    if (cell.isActive)
                        return root.accent;
                    return Qt.alpha(Globals.surfaceVariantContent, (cell.occupied ? 0.55 : 0.22) + (mouse.containsMouse ? 0.2 : 0));
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    Globals.dismissPopup();
                    Quickshell.execDetached(["sh", "-c", 'niri msg action focus-monitor "$1" && niri msg action focus-workspace "$2"', "niri-workspace", root.screenName, String(cell.modelData.idx)]);
                }
            }
        }
    }
}
