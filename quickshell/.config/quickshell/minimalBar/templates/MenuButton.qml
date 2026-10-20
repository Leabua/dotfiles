import QtQuick
import QtQuick.Layouts
import qs.templates

Rectangle {
    id: button

    property string text: ""
    property string icon: ""
    property bool destructive: false
    signal clicked

    readonly property color foreground: destructive && mouse.containsMouse ? Globals.criticalColor : Qt.alpha(Globals.fgColor, 0.75)

    implicitWidth: text === "" ? 28 : content.implicitWidth + 16
    implicitHeight: 28
    radius: 7
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.35
    color: Qt.alpha(Globals.fgColor, mouse.pressed ? 0.1 : mouse.containsMouse || activeFocus ? 0.06 : 0)
    scale: mouse.pressed ? 0.96 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 6

        MenuIcon {
            visible: button.icon !== ""
            name: button.icon
            color: button.foreground
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
        }

        Text {
            visible: button.text !== ""
            text: button.text
            color: button.foreground
            font.family: Globals.textFont.family
            font.pixelSize: 12
            font.weight: Font.Medium
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: button.clicked()
    }
}
