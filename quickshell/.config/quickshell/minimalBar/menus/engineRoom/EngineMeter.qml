import QtQuick
import QtQuick.Layouts
import qs.templates

ColumnLayout {
    id: meter

    property string label: ""
    property string icon: "cpu"
    property real value: 0
    property color accent: Globals.fgColor
    spacing: 12

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        MenuIcon {
            name: meter.icon
            color: Qt.alpha(Globals.fgColor, 0.6)
        }

        Text {
            Layout.fillWidth: true
            text: meter.label
            color: Qt.alpha(Globals.fgColor, 0.7)
            font.family: Globals.textFont.family
            font.pixelSize: 13
            font.weight: Font.Medium
        }
    }

    RowLayout {
        spacing: 3

        Text {
            text: Math.round(meter.value * 100)
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: 36
            font.weight: Font.Medium
        }

        Text {
            text: "%"
            color: Qt.alpha(Globals.fgColor, 0.4)
            font.family: Globals.textFont.family
            font.pixelSize: 20
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 5
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 4
        radius: 2
        color: Qt.alpha(Globals.fgColor, 0.09)

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, meter.value))
            height: parent.height
            radius: parent.radius
            color: meter.accent
        }
    }
}
