import QtQuick
import qs.defaults

// A display-only text field for the reminders editor. There is no Qt TextInput:
// the Reminders PopupWindow owns exclusive keyboard focus and feeds keystrokes in
// (the same manual-keyboard model the launcher + clipboard use), so this is purely
// a surface showing the current draft text. 
Item {
    id: field

    property string value: ""
    property string placeholder: ""
    property real pixelSize: Globals.textFont.pixelSize
    property int weight: Globals.textFont.weight
    property bool active: false // is this the focused field
    signal tapped

    implicitHeight: line.implicitHeight + 6
    clip: true

    Row {
        id: line
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 1

        Text {
            id: valueText
            visible: field.value.length > 0
            text: field.value
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: field.pixelSize
            font.weight: field.weight
        }

        // placeholder only while empty and unfocused -> vanishes on focus or typing
        Text {
            visible: field.value.length === 0 && !field.active
            text: field.placeholder
            color: Qt.alpha(Globals.fgColor, 0.3)
            font.family: Globals.textFont.family
            font.pixelSize: field.pixelSize
            font.weight: field.weight - 100
        }

        Rectangle {
            id: caret
            width: 2
            height: field.pixelSize + 2
            radius: 1
            color: Globals.fgColor
            visible: field.active
            anchors.verticalCenter: parent.verticalCenter

            SequentialAnimation on opacity {
                running: field.active
                loops: Animation.Infinite
                NumberAnimation {
                    from: 1
                    to: 0.1
                    duration: 500
                    easing.type: Easing.InOutSine
                }
                NumberAnimation {
                    from: 0.1
                    to: 1
                    duration: 500
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    // focus underline
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        radius: 1
        color: Globals.fgColor
        opacity: field.active ? 0.4 : 0.12

        Behavior on opacity {
            NumberAnimation {
                duration: Globals.animFast
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -3
        cursorShape: Qt.IBeamCursor
        onClicked: field.tapped()
    }
}
