import QtQuick
import qs.templates

// Search row: the current query (or a placeholder when empty) and a blinking caret riding the end of the text. 
Item {
    id: input

    property string query: ""
    property bool active: true // drives caret blink

    implicitHeight: 34

    Text {
        id: queryText
        anchors.left: parent.left
        anchors.leftMargin: Globals.spacing
        anchors.verticalCenter: parent.verticalCenter
        text: input.query.length > 0 ? input.query : "Search apps…"
        color: input.query.length === 0 ? Qt.alpha(Globals.fgColor, 0.4) : Globals.fgColor
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize
        font.weight: Globals.textFont.weight
    }

    // caret sits just before the placeholder while empty, then trails the query
    Rectangle {
        id: caret
        width: 2
        height: Globals.textFont.pixelSize + 2
        color: Globals.fgColor
        anchors.verticalCenter: parent.verticalCenter
        x: input.query.length === 0 ? queryText.x - 4 : queryText.x + queryText.contentWidth + 2

        SequentialAnimation on opacity {
            running: input.active
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
