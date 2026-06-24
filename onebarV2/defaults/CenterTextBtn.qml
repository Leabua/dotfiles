import Quickshell.Io
import qs.defaults
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property int largestButton
    property string icon
    property string label
    property var runThis
    signal clicked

    // feeding this upstream as the size of a whatever the content is in future
    property int contentWidth: contentCol.implicitWidth

    implicitWidth: root.largestButton
    implicitHeight: implicitWidth

    radius: Globals.radius
    color: ma.containsMouse ? Globals.fgColor : "transparent"

    // border.width: Globals.borderWidth
    // border.color: Globals.borderColor

    ColumnLayout {
        id: contentCol
        spacing: Globals.spacing - 2
        anchors.centerIn: parent

        // icon
        Text {
            text: root.icon
            color: ma.containsMouse ? Globals.bgColor : Globals.fgColor
            font.pixelSize: Globals.textFont.pixelSize + 10
            font.family: Globals.textFont.family
            Layout.alignment: Qt.AlignHCenter
        }

        // text
        Text {
            text: root.label
            color: ma.containsMouse ? Globals.bgColor : Globals.fgColor
            font.pixelSize: Globals.textFont.pixelSize
            font.family: Globals.textFont.family
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
