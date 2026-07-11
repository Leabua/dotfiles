import QtQuick
import QtQuick.Layouts
import qs.templates
import qs.osd

// extracted from onebarV2 audio/VolumeOsd.qml -> reads OsdState instead of
// taking properties from shell.qml, and sits in the left island row
RowLayout {
    id: root
    visible: OsdState.active === "volume"
    spacing: Globals.spacing
    Layout.preferredWidth: OsdState.fixedWidth

    Text {
        id: icon
        text: {
            if (OsdState.volMuted)
                return String.fromCodePoint(0xF075F);
            if (OsdState.volPercent < 34)
                return String.fromCodePoint(0xF057F);
            if (OsdState.volPercent < 67)
                return String.fromCodePoint(0xF0580);
            return String.fromCodePoint(0xF057E);
        }
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize
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
            width: parent.width * (OsdState.volPercent / 100)
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
