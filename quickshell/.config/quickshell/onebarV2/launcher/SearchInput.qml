import QtQuick
import qs.defaults

// Search row: the current query (or a placeholder when empty) and a blinking
// caret riding the end of the text. No magnifier glyph - the heading above the
// search row carries the menu icon. There is no Qt TextField either; Launcher
// owns keyboard focus via PopupWindow and feeds `query` in directly, so this is a
// pure display surface (same approach bjarneo's OmniMenu uses).
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
        text: input.query.length > 0 ? input.query : "Search apps… or type a command"
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
