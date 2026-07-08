pragma ComponentBehavior: Bound
import QtQuick
import qs.defaults
import QtQuick.Layouts

Item {
    id: root
    property int brightness: 0
    property int maxBrightness: 1
    readonly property int percent: maxBrightness > 0 ? Math.round(brightness / maxBrightness * 100) : 0

    property int sliderHeight: parent.implicitHeight
    anchors {
        fill: parent
        leftMargin: Globals.marginsLeft
        rightMargin: Globals.marginsRight
    }
    visible: opacity > 0
    Behavior on opacity {
        NumberAnimation {
            duration: 150
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Globals.spacing

        Text {
            text: {
                if (root.percent < 35)
                    return String.fromCodePoint(0xF00DE);
                if (root.percent < 67)
                    return String.fromCodePoint(0xF00DF);
                return String.fromCodePoint(0xF00E0);
            }
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize 
            color: Globals.fgColor
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: root.sliderHeight / 4
            radius: root.sliderHeight
            color: Qt.alpha(Globals.fgColor, 0.25)

            Rectangle {
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: parent.width * (root.percent / 100)
                radius: parent.radius
                color: Globals.fgColor
                Behavior on width {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }
        }
    }
}
