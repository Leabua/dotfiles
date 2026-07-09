import QtQuick
import QtQuick.Layouts

Item {
    id: root
    property string icon: ""
    property string displayText: ""
    property string clickCmd: ""

    implicitHeight: row.implicitHeight
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row

        Text {
            text: root.icon
            font.family: Globals.textFont.family
            font.weight: Globals.textFont.weight
            font.pixelSize: Globals.barIconSize
            color: Globals.fgColor
            visible: text !== ""
        }

        Text {
            text: root.displayText
            font: Globals.textFont
            color: Globals.fgColor
            visible: text !== ""
        }
        MouseArea {
            id: mouse
            anchors.fill: parent
            anchors.margins: -1
            cursorShape: Qt.PointingHandCursor

            onClicked: {
                root.clickCmd;
            }
        }
    }
}
