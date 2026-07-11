import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.osd

RowLayout {
    id: root
    visible: OsdState.active === "brightness"
    spacing: Globals.spacing
    Layout.preferredWidth: OsdState.fixedWidth

    Text {
        id: icon
        text: {
            if (OsdState.brightPercent < 35)
                return String.fromCodePoint(0xF00DE);
            if (OsdState.brightPercent < 67)
                return String.fromCodePoint(0xF00DF);
            return String.fromCodePoint(0xF00E0);
        }
        font: Globals.textFont
        color: Globals.fgColor
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: icon.implicitHeight / 2.5
        radius: height
        color: Qt.alpha(Globals.fgColor, 0.25)

        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * (OsdState.brightPercent / 100)
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
