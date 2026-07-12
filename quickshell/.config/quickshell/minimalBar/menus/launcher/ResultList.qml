pragma ComponentBehavior: Bound

import QtQuick
import qs.templates

/* Scrollable result list. Layout (40px rows, icon + title + category) and the
selection styling are both from bjarneo's OmniMenu (need to link the github for that in here). */

Item {
    id: rl

    property var results: []
    property int selectedIndex: 0

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
            height: 40
            readonly property bool sel: rl.selectedIndex === index

            // row background: faint tint on the active row
            Rectangle {
                anchors.fill: parent
                anchors.rightMargin: 2
                radius: Globals.radius
                color: row.sel ? Qt.alpha(Globals.fgColor, 0.15) : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: Globals.animFast
                    }
                }
            }

            // short colour bar on the left edge marks the active row; fades with the
            // same timing as the row tint so the two move together
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.topMargin: Globals.spacing
                anchors.bottomMargin: Globals.spacing
                width: 3
                radius: 2
                color: Globals.fgColor
                opacity: row.sel ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: Globals.animFast
                    }
                }
            }

            // icon: real app icon when resolvable, else a glyph that picks up the selection colours
            Item {
                id: iconBox
                anchors.left: parent.left
                anchors.leftMargin: Globals.spacing + 6
                anchors.verticalCenter: parent.verticalCenter
                width: 22
                height: 22
                readonly property bool hasImg: row.modelData.iconUrl !== "" && img.status === Image.Ready

                Image {
                    id: img
                    anchors.fill: parent
                    source: row.modelData.iconUrl
                    sourceSize.width: 44
                    sourceSize.height: 44
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    cache: true
                    visible: iconBox.hasImg
                }

                Text {
                    anchors.centerIn: parent
                    visible: !iconBox.hasImg
                    text: row.modelData.glyph || "󰣆"
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.weight: Globals.textFont.weight
                    font.pixelSize: Globals.textFont.pixelSize + 2
                }
            }

            Text {
                id: titleText
                anchors.left: iconBox.right
                anchors.leftMargin: Globals.spacing + 6
                anchors.right: catText.left
                anchors.rightMargin: Globals.spacing
                anchors.verticalCenter: parent.verticalCenter
                text: row.modelData.title
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight
                elide: Text.ElideRight
            }

            Text {
                id: catText
                anchors.right: parent.right
                anchors.rightMargin: Globals.spacing + 8
                anchors.verticalCenter: parent.verticalCenter
                text: (row.modelData.category || "").toUpperCase()
                color: Qt.alpha(Globals.fgColor, row.sel ? 0.7 : 0.45)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 4
                font.letterSpacing: 2
                elide: Text.ElideLeft
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
            text: "NOTHING MATCHES"
            color: Qt.alpha(Globals.fgColor, 0.4)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 3
            font.letterSpacing: 3
        }
    }
}
