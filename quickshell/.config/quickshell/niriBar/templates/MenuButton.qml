import QtQuick
import QtQuick.Layouts
import qs.templates

// M3 buttons: with a label it's a tonal pill (secondary container); icon-only it's a round standard icon
// button. Destructive tonal buttons switch to the error container on hover
Rectangle {
    id: button

    property string text: ""
    property string icon: ""
    property bool destructive: false
    signal clicked

    readonly property bool iconOnly: text === ""
    readonly property color foreground: {
        if (iconOnly)
            return Globals.surfaceVariantContent;
        return destructive && mouse.containsMouse ? Globals.errorContainerContent : Globals.secondaryContainerContent;
    }
    readonly property color base: {
        if (iconOnly)
            return "transparent";
        return destructive && mouse.containsMouse ? Globals.errorContainer : Globals.secondaryContainer;
    }

    implicitWidth: iconOnly ? 40 : content.implicitWidth + 32
    implicitHeight: 40
    radius: height / 2
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.38
    color: base
    Behavior on color {
        ColorAnimation {
            duration: Globals.animFast
        }
    }
    scale: mouse.pressed ? 0.95 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    // state layer
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: button.foreground
        opacity: mouse.pressed ? Globals.statePressed : mouse.containsMouse ? Globals.stateHover : button.activeFocus ? Globals.stateFocus : 0
    }

    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 8

        MenuIcon {
            visible: button.icon !== ""
            name: button.icon
            color: button.foreground
            Layout.preferredWidth: button.iconOnly ? 22 : 18
            Layout.preferredHeight: button.iconOnly ? 22 : 18
        }

        Text {
            visible: button.text !== ""
            text: button.text
            color: button.foreground
            font: Globals.labelLarge
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
