import QtQuick
import QtQuick.Layouts
import qs.defaults

Item {
    id: root
    property int volPercent: 0
    property bool muted: false
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
                if (root.muted || root.volPercent === 0)
                    return String.fromCodePoint(0xF075F);
                if (root.volPercent < 34)
                    return String.fromCodePoint(0xF057F);
                if (root.volPercent < 67)
                    return String.fromCodePoint(0xF0580);
                return String.fromCodePoint(0xF057E);
            }
            font: Globals.textFont
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
                width: parent.width * (root.volPercent / 100)
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
