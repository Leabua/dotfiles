pragma ComponentBehavior: Bound

import QtQuick
import qs.templates

/* Scrollable result list. Row layout (icon + title + category) started from
bjarneo's OmniMenu (github.com/bjarneo/quickshelldots), restyled to the menu row kit. */

Item {
    id: rl

    property var results: []
    property int selectedIndex: 0
    readonly property int contentInset: 10

    signal hovered(int index)
    signal activated(int index)

    ListView {
        id: view
        anchors.fill: parent
        model: rl.results
        currentIndex: rl.selectedIndex
        highlightFollowsCurrentItem: false
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        cacheBuffer: 200
        pixelAligned: true

        // keep the keyboard-selected row scrolled into view
        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

        // the default wheel step is tiny on a touchpad; scale it up and drive
        // contentY directly so scrolling feels responsive (bump scrollSpeed to taste)

        WheelHandler {
            property real scrollSpeed: 2
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                const maxY = Math.max(0, view.contentHeight - view.height);
                view.contentY = Math.max(0, Math.min(maxY, view.contentY - event.angleDelta.y * scrollSpeed));
            }
        }

        delegate: Item {
            id: row
            required property var modelData
            required property int index

            width: ListView.view.width
            height: 44
            readonly property bool sel: rl.selectedIndex === index

            // selection moves with the keyboard dozens of times a minute -> no transition, it just is
            Rectangle {
                anchors.fill: parent
                radius: 9
                color: Qt.alpha(Globals.fgColor, row.sel ? 0.11 : 0)
            }

            // real app icon when resolvable, else a neutral app glyph
            Item {
                id: iconBox
                anchors.left: parent.left
                anchors.leftMargin: rl.contentInset
                anchors.verticalCenter: parent.verticalCenter
                width: 24
                height: 24
                readonly property bool hasImg: row.modelData.iconUrl !== "" && img.status === Image.Ready

                Image {
                    id: img
                    anchors.fill: parent
                    source: row.modelData.iconUrl
                    sourceSize.width: 48
                    sourceSize.height: 48
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    cache: true
                    visible: iconBox.hasImg
                }

                MenuIcon {
                    anchors.centerIn: parent
                    visible: !iconBox.hasImg
                    name: "grid"
                    color: Qt.alpha(Globals.fgColor, 0.6)
                }
            }

            Text {
                id: titleText
                anchors.left: iconBox.right
                anchors.leftMargin: 12
                anchors.right: catText.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.title
                textFormat: Text.PlainText
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                id: catText
                width: Math.min(implicitWidth, row.width * 0.3)
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.category || ""
                color: Qt.alpha(Globals.fgColor, row.sel ? 0.6 : 0.4)
                font.family: Globals.textFont.family
                font.pixelSize: 12
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignRight
            }

            MouseArea {
                id: rowMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onPositionChanged: rl.hovered(row.index)
                onClicked: rl.activated(row.index)
            }
        }

        // empty state
        Text {
            anchors.centerIn: parent
            visible: view.count === 0
            text: "No apps match"
            color: Qt.alpha(Globals.fgColor, 0.5)
            font.family: Globals.textFont.family
            font.pixelSize: 13
        }
    }
}
