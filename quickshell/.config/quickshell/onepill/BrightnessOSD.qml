pragma ComponentBehavior: Bound

import Quickshell
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: osdLayout
    spacing: 6
    implicitWidth: 120
    implicitHeight: 12

    property color fgColor: "#FFFFFF"

    Text {
        text: "󰃠"
        font.family: global.shellFont.family
        font.pixelSize: 11
        font.bold: true
        color: osdLayout.fgColor
        Layout.alignment: Qt.AlignVCenter
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 80
        implicitHeight: 4
        radius: 2
        color: Qt.rgba(osdLayout.fgColor.r, osdLayout.fgColor.g, osdLayout.fgColor.b, 0.15)

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            implicitWidth: parent.width * global.brightnessVal
            radius: 2
            color: osdLayout.fgColor
        }
    }
}
