import QtQuick
import qs.templates

// Search well: the current query (or a placeholder when empty) with a caret
// riding the end of the text. Keys arrive through Launcher.handleKey.
Rectangle {
    id: input

    property string query: ""
    property bool active: true // drives caret blink

    implicitHeight: 44
    radius: 10
    color: Qt.lighter(Globals.bgColor, 1.35)

    MenuIcon {
        id: glass
        x: 13
        anchors.verticalCenter: parent.verticalCenter
        name: "search"
        color: Qt.alpha(Globals.fgColor, 0.45)
    }

    Text {
        id: queryText
        anchors.left: glass.right
        anchors.leftMargin: 11
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: input.query.length > 0 ? input.query : "Search apps"
        textFormat: Text.PlainText
        color: input.query.length === 0 ? Qt.alpha(Globals.fgColor, 0.4) : Globals.fgColor
        font.family: Globals.textFont.family
        font.pixelSize: 15
        elide: Text.ElideLeft
    }

    // caret shares the placeholder's left edge while empty, then trails the query
    Rectangle {
        width: 2
        height: 18
        radius: 1
        color: Globals.fgColor
        anchors.verticalCenter: parent.verticalCenter
        x: queryText.x + (input.query.length === 0 ? 0 : Math.min(queryText.width, queryText.contentWidth) + 1)

        SequentialAnimation on opacity {
            running: input.active
            loops: Animation.Infinite
            NumberAnimation {
                from: 1
                to: 0.15
                duration: 530
                easing.type: Easing.InOutSine
            }
            NumberAnimation {
                from: 0.15
                to: 1
                duration: 530
                easing.type: Easing.InOutSine
            }
        }
    }
}
