import Quickshell.Io
import qs.templates
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    property int largestButton
    property string icon
    property string label
    property var runThis: [] // button specific operation or command
    signal clicked
    property bool isActive: false

    property int contentWidth: contentCol.implicitWidth

    // a button row sets largestButton so every toggle matches the widest one;
    // a lone button leaves it unset -> fall back to hugging its own content
    implicitWidth: root.largestButton > 0 ? root.largestButton : contentCol.implicitWidth + Globals.padding
    implicitHeight: contentCol.implicitHeight + Globals.spacing

    radius: Globals.radius
    color: isActive ? Globals.fgColor : (ma.containsMouse ? Globals.fgColor : "transparent")

    RowLayout {
        id: contentCol
        spacing: Globals.spacing
        anchors.centerIn: parent

        Text {
            text: root.icon
            visible: Globals.buttonIcons && text !== ""
            color: root.isActive ? Globals.bgColor : (ma.containsMouse ? Globals.bgColor : Globals.fgColor)
            font.pixelSize: Globals.textFont.pixelSize + 2
            font.family: Globals.textFont.family
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.label
            visible: root.label !== ""
            color: root.isActive ? Globals.bgColor : (ma.containsMouse ? Globals.bgColor : Globals.fgColor)
            font.pixelSize: Globals.textFont.pixelSize
            font.family: Globals.textFont.family
            font.weight: Globals.textFont.weight - 100
            Layout.alignment: Qt.AlignVCenter
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
            if (root.runThis && root.runThis.length > 0)
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
