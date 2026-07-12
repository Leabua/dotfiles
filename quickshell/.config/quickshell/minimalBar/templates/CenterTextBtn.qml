import Quickshell.Io
import qs.templates
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property int largestButton
    property string icon
    property string label
    property var runThis: [] // empty by default -> view-switch buttons carry no command
    signal clicked
    property bool isActive: false // keep button coloured if it is already active

    property int contentWidth: contentCol.implicitWidth // feeding this upstream as the size of a whatever the content is in future

    implicitWidth: root.largestButton

    implicitHeight: contentCol.implicitHeight + Globals.spacing

    radius: Globals.radius
    color: isActive ? Globals.fgColor : (ma.containsMouse ? Globals.fgColor : "transparent")

    // border.width: Globals.borderWidth //-> if I ever wanted borders for buttons again
    // border.color: Globals.borderColor

    ColumnLayout {
        id: contentCol
        spacing: Globals.spacing - 4
        anchors.centerIn: parent

        // icon
        Text {
            text: root.icon
            visible: Globals.buttonIcons
            color: root.isActive ? Globals.bgColor : (ma.containsMouse ? Globals.bgColor : Globals.fgColor)
            font.pixelSize: Globals.textFont.pixelSize + 28
            font.family: Globals.textFont.family
            Layout.alignment: Qt.AlignHCenter
        }

        // text -> dropped (excluded from the layout) when empty so the button can be icon-only
        Text {
            text: root.label
            visible: root.label !== ""
            color: root.isActive ? Globals.bgColor : (ma.containsMouse ? Globals.bgColor : Globals.fgColor)
            font.pixelSize: Globals.textFont.pixelSize
            font.family: Globals.textFont.family
            font.weight: Globals.textFont.weight - 100
            Layout.alignment: Qt.AlignHCenter
        }
    }

    Process {
        id: commandProcess
        command: root.runThis
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: {
            if (root.runThis && root.runThis.length > 0) // some buttons only switch views and have no command
                commandProcess.running = true;
            root.clicked();
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}
