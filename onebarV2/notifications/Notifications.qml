import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.defaults
import QtQuick
import QtQuick.Layouts

// TODO figure out how to attached Escape as a close command for everything. I imagine the way is t focus it first and then press Escape
Scope {
    id: root

    property bool centerOpen: false

    ListModel {
        id: history
    }

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        imageSupported: true
        onNotification: n => {
            history.insert(0, {
                summary: n.summary,
                body: n.body,
                appName: n.appName,
                urgency: n.urgency,
                time: Qt.formatDateTime(new Date(), "HH:mm")
            });
            n.tracked = true;
        }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void {
            root.centerOpen = !root.centerOpen;
        }
        function show(): void {
            root.centerOpen = true;
        }
        function hide(): void {
            root.centerOpen = false;
        }
    }

    // incoming toast notification
    PanelWindow { // qmllint disable uncreatable-type
        anchors {
            top: true
            right: true
        }
        margins {
            top: Globals.marginsTop
            right: Globals.marginsRight
        }
        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        ColumnLayout {
            id: column
            width: parent.width
            spacing: Globals.spacing

            Repeater {
                model: server.trackedNotifications
                delegate: Rectangle {
                    id: card
                    required property var modelData

                    Timer {
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        interval: 5000
                        onTriggered: card.modelData.dismiss()
                    }

                    Layout.fillWidth: true
                    Layout.preferredHeight: cardLayout.implicitHeight + 20
                    radius: 8
                    color: Globals.bgColor
                    border.width: 2
                    border.color: card.modelData.urgency === NotificationUrgency.Critical ? Globals.criticalColor : Globals.fgColor

                    RowLayout {
                        id: cardLayout
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Globals.marginDefault
                        }
                        spacing: Globals.spacing

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Globals.fgColor
                                font.family: Globals.textFont.family
                                font.pixelSize: Globals.textFont.pixelSize + 2
                                font.weight: Globals.textFont.weight
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.body
                                color: Globals.fgColor
                                font.family: Globals.textFont.family
                                font.pixelSize: Globals.textFont.pixelSize - 1
                                wrapMode: Text.WordWrap
                                visible: card.modelData.body !== ""
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }

    // notification center
    PanelWindow { // qmllint disable uncreatable-type
        id: centerWindow
        visible: root.centerOpen
        anchors {
            top: true
            right: true
        }
        margins {
            top: Globals.marginsTop
            right: Globals.marginsRight
        }
        implicitWidth: 380
        implicitHeight: container.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore

        Rectangle {
            id: container
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            implicitHeight: centerCol.implicitHeight + 24
            radius: 10
            color: Globals.bgColor
            border.width: 2
            border.color: Globals.fgColor

            ColumnLayout {
                id: centerCol
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                    margins: 12
                }
                spacing: Globals.spacing + 2

                // header row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Globals.spacing

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Globals.fgColor
                        font.family: Globals.textFont.family
                        font.pixelSize: Globals.textFont.pixelSize + 2
                        font.weight: Globals.textFont.weight
                    }

                    Text {
                        text: "Clear all"
                        visible: history.count > 0
                        color: Globals.criticalColor
                        font.family: Globals.textFont.family
                        font.pixelSize: Globals.textFont.pixelSize - 1
                        MouseArea {
                            anchors.fill: parent
                            onClicked: history.clear()
                            anchors.margins: -1
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }

                // empty state
                Text {
                    visible: history.count === 0
                    Layout.fillWidth: true
                    text: "No notifications"
                    color: Qt.alpha(Globals.fgColor, 0.4)
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize - 1
                    horizontalAlignment: Text.AlignHCenter
                }

                // history list if not empty
                Repeater {
                    id: rep
                    model: history
                    delegate: Item {
                        // Item wrapper handles the height animation and clipping
                        // so the inner Rectangle never bleeds its border outside -> needs way more work - works well on increase sucks on decrease
                        id: delegateWrapper
                        Layout.fillWidth: true
                        property bool removing: false
                        Layout.preferredHeight: inner.implicitHeight

                        Behavior on Layout.preferredHeight {
                            NumberAnimation {
                                duration: 60
                                easing.type: Easing.OutCubic
                            }
                        }

                        Rectangle {
                            id: inner
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }
                            // height tracks parent so it collapses with it
                            height: parent.Layout.preferredHeight - (delegateWrapper.removing ? 0 : 0)
                            implicitHeight: historyLayout.implicitHeight + 16
                            radius: 8
                            color: Globals.bgColor
                            border.width: 2
                            border.color: Globals.fgColor

                            ColumnLayout {
                                id: historyLayout
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    margins: 8
                                }
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: Globals.spacing

                                    Text {
                                        Layout.fillWidth: true
                                        text: model.summary
                                        color: Globals.fgColor
                                        font.family: Globals.textFont.family
                                        font.pixelSize: Globals.textFont.pixelSize
                                        font.weight: Globals.textFont.weight
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: model.time
                                        color: Globals.fgColor2
                                        font.family: Globals.textFont.family
                                        font.pixelSize: Globals.textFont.pixelSize - 3
                                        font.weight: Globals.textFont.weight + 100
                                    }

                                    Text {
                                        text: "󰖭"
                                        color: Globals.fgColor2
                                        font.family: Globals.textFont.family
                                        font.pixelSize: Globals.textFont.pixelSize - 1
                                        font.weight: Globals.textFont.weight + 100
                                        MouseArea {
                                            anchors.fill: parent
                                            anchors.margins: -4
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                // animate out first, then remove
                                                delegateWrapper.removing = true;
                                                removeTimer.start();
                                            }
                                        }
                                        Timer {
                                            id: removeTimer
                                            interval: 210 // just after the 200ms animation
                                            onTriggered: history.remove(index)
                                        }
                                    }
                                }

                                Text {
                                    visible: model.body !== ""
                                    text: model.body
                                    color: Globals.fgColor
                                    font.family: Globals.textFont.family
                                    font.pixelSize: Globals.textFont.pixelSize - 1
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }

                                Text {
                                    visible: model.appName !== ""
                                    text: model.appName
                                    color: Globals.fgColor2
                                    font.family: Globals.textFont.family
                                    font.pixelSize: Globals.textFont.pixelSize - 3
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
