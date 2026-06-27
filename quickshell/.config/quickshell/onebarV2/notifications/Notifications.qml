pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.defaults
import QtQuick
import QtQuick.Layouts

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

        screen: Globals.focusedScreen // toasts follow the focused monitor instead of a fixed one
        visible: !root.centerOpen // don't show toasts while the notification center is open (they'd overlap if otherwise)
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
        // draw toasts above fullscreen windows
        WlrLayershell.layer: WlrLayer.Overlay

        ColumnLayout {
            id: column
            width: parent.width
            spacing: Globals.spacing - 2

            Repeater {
                model: server.trackedNotifications
                delegate: Item {
                    id: card
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: cardRect.implicitHeight

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: Globals.animFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    Timer {
                        running: true
                        interval: card.modelData.urgency === NotificationUrgency.Critical ? 15000 : 5000
                        onTriggered: card.modelData.dismiss()
                    }

                    Rectangle {
                        id: cardRect
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                        height: parent.Layout.preferredHeight
                        implicitHeight: cardLayout.implicitHeight + 18
                        radius: Globals.radius
                        color: Globals.menuBg
                        border.width: Globals.borderWidth
                        border.color: card.modelData.urgency === NotificationUrgency.Critical ? Globals.criticalColor : Globals.fgColor
                        layer.enabled: true // should stop screen smeer on resize

                        RowLayout {
                            id: cardLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: Globals.margins
                            }
                            spacing: Globals.spacing

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: Globals.spacing / 3

                                Text {
                                    Layout.fillWidth: true
                                    text: card.modelData.summary
                                    color: Globals.fgColor
                                    font.family: Globals.textFont.family
                                    font.pixelSize: Globals.textFont.pixelSize
                                    font.weight: Globals.textFont.weight
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: card.modelData.body
                                    color: Globals.fgColor
                                    font.family: Globals.textFont.family
                                    font.weight: Globals.textFont.weight
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
    }

    // notification center
    // PopupWindow provides the full-screen catcher, Escape-to-close and
    // outside-click dismissal; the card is anchored top-right via hAlign.
    PopupWindow {
        open: root.centerOpen
        onDismissed: root.centerOpen = false
        hAlign: "right"
        screen: Globals.focusedScreen // open the center on the focused monitor

        margins {
            top: Globals.marginsTop
            right: Globals.marginsRight
        }

        ColumnLayout {
            id: centerCol
            width: 360 // PopupWindow padding (Globals.margins) brings the card to ~380
            spacing: Globals.spacing + 1

            // header row
            RowLayout {
                Layout.fillWidth: true
                spacing: Globals.spacing

                Text {
                    text: String.fromCodePoint(0xF009A) // nf-md-bell 󰂚
                    visible: Globals.headerIcons
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 6
                    font.weight: Globals.textFont.weight
                }

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
                    font.weight: Globals.textFont.weight

                    MouseArea {
                        anchors.fill: parent
                        onClicked: history.clear()
                        anchors.margins: -1
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            MenuDivider {}

            // empty state
            Text {
                visible: history.count === 0
                Layout.fillWidth: true
                text: "No notifications"
                color: Qt.alpha(Globals.fgColor, 0.4)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 1
                font.weight: Globals.textFont.weight - 100
                horizontalAlignment: Text.AlignHCenter
            }

            // history list if not empty
            Repeater {
                id: rep
                model: history
                delegate: Item {
                    // transparent wrapper drives the layout; the bordered card is anchored inside and clipped while removing, so it collapses smoothly on dismiss.
                    id: delegateWrapper
                    // bind the ListModel roles as required properties (the Qt6 way) -> reaching
                    // for the `model` context object directly throws "model is not defined"
                    required property int index
                    required property string summary
                    required property string body
                    required property string appName
                    required property string time
                    property bool removing: false
                    Layout.fillWidth: true
                    Layout.preferredHeight: removing ? 0 : inner.implicitHeight

                    clip: removing
                    opacity: removing ? 0 : 1

                    Behavior on Layout.preferredHeight {
                        NumberAnimation {
                            duration: Globals.animFast
                            easing.type: Easing.OutCubic
                        }
                    }
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Globals.animFast
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
                        height: parent.Layout.preferredHeight
                        implicitHeight: historyLayout.implicitHeight + Globals.spacing * 2
                        radius: Globals.radius
                        // transparent so the panel's translucency shows through uniformly
                        // (border alone defines the card)
                        color: "transparent"
                        border.width: Globals.borderWidth
                        border.color: Globals.fgColor

                        // composite through an offscreen buffer so the border can't smear while cards resize/collapse during reflowt
                        layer.enabled: true

                        ColumnLayout {
                            id: historyLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: Globals.spacing
                            }
                            // tight spacing between summary / body / app name
                            spacing: Globals.spacing / 3

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: Globals.spacing

                                Text {
                                    Layout.fillWidth: true
                                    text: delegateWrapper.summary
                                    color: Globals.fgColor
                                    font.family: Globals.textFont.family
                                    font.pixelSize: Globals.textFont.pixelSize
                                    font.weight: Globals.textFont.weight
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: delegateWrapper.time
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
                                        interval: Globals.animFast + 30
                                        onTriggered: history.remove(delegateWrapper.index)
                                    }
                                }
                            }

                            Text {
                                visible: delegateWrapper.body !== ""
                                text: delegateWrapper.body
                                color: Globals.fgColor
                                font.family: Globals.textFont.family
                                font.weight: Globals.textFont.weight
                                font.pixelSize: Globals.textFont.pixelSize - 1
                                wrapMode: Text.WordWrap
                                Layout.fillWidth: true
                            }

                            Text {
                                visible: delegateWrapper.appName !== ""
                                text: delegateWrapper.appName
                                color: Globals.fgColor2
                                font.family: Globals.textFont.family
                                font.weight: Globals.textFont.weight
                                font.pixelSize: Globals.textFont.pixelSize - 3
                            }
                            Text { // blankline for spacer
                                visible: history.count > 0
                                text: " "
                                color: Globals.fgColor2
                                font.family: Globals.textFont.family
                                font.weight: Globals.textFont.weight
                                font.pixelSize: Globals.spacing
                            }
                            MenuDivider {}
                        }
                    }
                }
            }
        }
    }
}
