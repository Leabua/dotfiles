import QtQuick
import qs.templates

// MenuButton scaled up for media transport; `primary` keeps a standing wash (play / pause)
Rectangle {
    id: button

    property string icon: ""
    property int size: 34
    property int iconSize: 18
    property bool primary: false
    signal clicked

    implicitWidth: size
    implicitHeight: size
    radius: primary ? size / 2 : 9
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.35
    color: Qt.alpha(Globals.fgColor, mouse.pressed ? 0.22 : primary ? (mouse.containsMouse ? 0.18 : 0.12) : mouse.containsMouse || activeFocus ? 0.08 : 0)
    scale: mouse.pressed ? 0.94 : 1

    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()

    MenuIcon {
        anchors.centerIn: parent
        width: button.iconSize
        height: button.iconSize
        name: button.icon
        color: Qt.alpha(Globals.fgColor, button.primary ? 1 : 0.8)
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
