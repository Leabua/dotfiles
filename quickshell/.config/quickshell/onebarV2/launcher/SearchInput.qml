import QtQuick
import qs.defaults

// Search row: magnifier glyph, the current query (or a placeholder when empty),
// and a blinking caret riding the end of the text. There is no Qt TextField -
// Launcher owns keyboard focus via PopupWindow and feeds `query` in directly, so
// this is a pure display surface (same approach bjarneo's OmniMenu uses).
Item {
    id: input

    property string query: ""
    property bool active: true // drives caret blink

    implicitHeight: 34

    Text {
        id: searchPrompt
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        text: "󰍉" // nf-md-magnify
        color: Globals.fgColor
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize + 1
        font.weight: Globals.textFont.weight
    }

    Text {
        id: queryText
        anchors.left: searchPrompt.right
        anchors.leftMargin: Globals.spacing + 4
        anchors.verticalCenter: parent.verticalCenter
        text: input.query.length > 0 ? input.query : "Search apps… or type a command"
        color: input.query.length === 0 ? Qt.alpha(Globals.fgColor, 0.4) : Globals.fgColor
        font.family: Globals.textFont.family
        font.pixelSize: Globals.textFont.pixelSize
        font.weight: Globals.textFont.weight
    }

    // caret sits after the prompt while empty, then trails the query text
    Rectangle {
        id: caret
        width: 2
        height: Globals.textFont.pixelSize + 2
        color: Globals.fgColor
        anchors.verticalCenter: parent.verticalCenter
        x: input.query.length === 0 ? searchPrompt.x + searchPrompt.width + Globals.spacing + 4 : queryText.x + queryText.contentWidth + 2

        SequentialAnimation on opacity {
            running: input.active
            loops: Animation.Infinite
            NumberAnimation {
                from: 1
                to: 0.2
                duration: 600
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                from: 0.2
                to: 1
                duration: 600
                easing.type: Easing.InOutSine
            }
        }
    }
}
