import QtQuick
import qs.templates

// Native editing supports selection, paste, cursor movement and undo.
Item {
    id: field

    property string value: ""
    property string placeholder: ""
    property real pixelSize: Globals.textFont.pixelSize
    property int weight: Globals.textFont.weight
    property bool active: false
    property bool multiline: false
    signal tapped
    signal edited(string value)
    signal keyPressed(var event)

    implicitHeight: Math.min(multiline ? 220 : 60, Math.max(multiline ? 120 : 34, editor.contentHeight + 16))

    onActiveChanged: {
        if (active)
            Qt.callLater(editor.forceActiveFocus);
    }
    Component.onCompleted: {
        if (active)
            editor.forceActiveFocus();
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.alpha(Globals.fgColor, field.active ? 0.08 : 0.03)
        radius: Globals.radius
    }

    Flickable {
        id: scroll
        anchors.fill: parent
        anchors.margins: 8
        clip: true
        contentWidth: width
        contentHeight: editor.height
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        TextEdit {
            id: editor
            width: scroll.width
            height: Math.max(scroll.height, contentHeight)
            text: field.value
            textFormat: TextEdit.PlainText
            wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
            color: Globals.fgColor
            selectionColor: Globals.fgColor
            selectedTextColor: Globals.bgColor
            font.family: Globals.textFont.family
            font.pixelSize: field.pixelSize
            font.weight: field.weight
            selectByMouse: true
            activeFocusOnPress: true
            onActiveFocusChanged: {
                if (activeFocus)
                    field.tapped();
            }
            onTextChanged: {
                if (activeFocus && text !== field.value)
                    field.edited(text);
            }
            onCursorRectangleChanged: {
                if (cursorRectangle.y < scroll.contentY)
                    scroll.contentY = cursorRectangle.y;
                else if (cursorRectangle.y + cursorRectangle.height > scroll.contentY + scroll.height)
                    scroll.contentY = cursorRectangle.y + cursorRectangle.height - scroll.height;
            }
            Keys.onPressed: event => {
                event.accepted = false;
                field.keyPressed(event);
            }
        }

        Text {
            visible: editor.text.length === 0
            text: field.placeholder
            color: Qt.alpha(Globals.fgColor, 0.4)
            font.family: Globals.textFont.family
            font.pixelSize: field.pixelSize
            font.weight: field.weight - 100
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Qt.alpha(Globals.fgColor, field.active ? 0.5 : 0.15)
    }
}
