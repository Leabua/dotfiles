import Quickshell.Io
import qs.templates
import QtQuick
import QtQuick.Layouts

// TODO this was a copy and paste so we need to see how we can make this look better
Rectangle {
    id: root
    property int largestButton
    property string icon
    property string label
    property var runThis: [] // button specific operation or command
    signal clicked
    property bool isActive: false

    property int contentWidth: contentCol.implicitWidth // feeding this upstream as the size of a whatever the content is in future

    implicitWidth: root.largestButton

    implicitHeight: contentCol.implicitHeight + Globals.spacing

    radius: Globals.radius
    color: isActive ? Globals.fgColor : (ma.containsMouse ? Globals.fgColor : "transparent")

    ColumnLayout {
        id: contentCol
        spacing: Globals.spacing - 4
        anchors.centerIn: parent

        // icon
        Text {
            text: root.icon
            visible: Globals.buttonIcons
            color: root.isActive ? Globals.bgColor : (ma.containsMouse ? Globals.bgColor : Globals.fgColor)
            font.pixelSize: Globals.bigIcon
            font.family: Globals.textFont.family
            Layout.alignment: Qt.AlignHCenter
        }

        // text
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
