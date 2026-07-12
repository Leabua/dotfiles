import Quickshell
import Quickshell.Io
import QtQuick
import qs.templates
import qs.barModules
// ------- menu modules: registered so the path-loaded menus can self-import their siblings -------
import qs.menus.wifi
import qs.menus.audio
import qs.menus.engineRoom
import qs.menus.launcher
import qs.menus.reminders

ShellRoot {
    id: root

    // ------- bar visibility -------
    property bool barVisible: true          // whole bar -> super + shift + space
    property bool rightIslandVisible: true  // right cluster only -> super + alt + space (visible by default)

    Variants {
        model: Quickshell.screens
        PanelWindow { // qmllint disable uncreatable-type
            property var modelData
            screen: modelData
            color: "transparent"

            visible: root.barVisible

            // make go top
            anchors {
                top: true
                left: true
                right: true
            }

            // give some padding
            margins {
                top: Globals.marginsTop
                left: Globals.marginsLeft
                right: Globals.marginsRight
                bottom: Globals.marginsBottom
            }
            implicitHeight: defHeight.implicitHeight + Globals.vertPadding

            Text {
                id: defHeight
                visible: false // fixed height anchor so the bar never jitters
                text: " NEVER SHOW THIS"
                font: Globals.textFont
            }

            // ------- mirror bar height + shown-state so menus sit below the bar and shift when it hides -------
            Binding {
                target: Globals
                property: "currentBarHeight"
                value: leftIsland.implicitHeight
            }
            Binding {
                target: Globals
                property: "barShown"
                value: root.barVisible
            }

            // literally some rectangles with positions -> refer to the actual files for whats going on
            BarLeft {
                id: leftIsland
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                }
            }

            BarMiddle {
                anchors.centerIn: parent
            }

            BarRight {
                visible: root.rightIslandVisible
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    // ------- menus: mounted once, opened via bar clicks / ipc -------
    LazyLoader {
        source: "menus/wifi/WifiMenu.qml"
        active: true
    }
    LazyLoader {
        source: "menus/audio/AudioMenu.qml"
        active: true
    }
    LazyLoader {
        source: "menus/engineRoom/EngineRoom.qml"
        active: true
    }
    LazyLoader {
        source: "menus/powerProfiles/PowerProfiles.qml"
        active: true
    }
    LazyLoader {
        source: "menus/powerMenu/PowerMenu.qml"
        active: true
    }
    LazyLoader {
        source: "menus/notifications/Notifications.qml"
        active: true
    }
    LazyLoader {
        source: "menus/reminders/Reminders.qml"
        active: true
    }
    LazyLoader {
        source: "menus/clipboard/Clipboard.qml"
        active: true
    }
    LazyLoader {
        source: "menus/launcher/Launcher.qml"
        active: true
    }

    // ------- hide the whole bar -> super + shift + space -------
    IpcHandler {
        target: "bar"
        function toggle(): void {
            root.barVisible = !root.barVisible;
        }
        function show(): void {
            root.barVisible = true;
        }
        function hide(): void {
            root.barVisible = false;
        }
    }

    // ------- toggle just the right island -> super + alt + space -------
    IpcHandler {
        target: "rightIsland"
        function toggle(): void {
            root.rightIslandVisible = !root.rightIslandVisible;
        }
        function show(): void {
            root.rightIslandVisible = true;
        }
        function hide(): void {
            root.rightIslandVisible = false;
        }
    }
}
