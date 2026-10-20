pragma ComponentBehavior: Bound
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.templates
import QtQuick
import QtQuick.Layouts

// tony banters yt

Scope {
    id: root

    property bool centerOpen: false

    // the live persistent low-battery toast, so we can pull it down once the laptop is charging again
    property var batteryCriticalNotif: null

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
            // remember the persistent battery warning so charging can dismiss it
            if (n.appName === "Battery" && n.urgency === NotificationUrgency.Critical)
                root.batteryCriticalNotif = n;
            n.tracked = true;
        }
    }

    // charging resumed -> retire the persistent 10% warning
    Connections {
        target: Globals
        function onBatteryChargingChanged(): void {
            if (Globals.batteryCharging && root.batteryCriticalNotif) {
                root.batteryCriticalNotif.dismiss();
                root.batteryCriticalNotif = null;
            }
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
        id: toast

        screen: Globals.focusedScreen
        visible: !root.centerOpen // don't show toasts while the notification center is open (they'd overlap if otherwise)

        // ~~~ clear the bar strip when it's up ~~~
        readonly property real barDrop: Globals.barShown ? Globals.currentBarHeight + Globals.hyprGaps : 0

        // ~~~ the toast column rides the right edge -> measure its scene span there so the overlap test tracks
        //     right-side menus (power profiles, wifi…) instead of the old left column ~~~
        readonly property real toastRightEdge: (toast.screen ? toast.screen.width : 0) - Globals.marginsRight
        readonly property real toastLeftEdge: toast.toastRightEdge - toast.implicitWidth

        // ~~~ an open menu card overlapping the toast column pushes them below it instead ~~~
        readonly property bool menuInWay: Globals.menuCardRect.width > 0 && Globals.menuCardRect.x < toast.toastRightEdge && Globals.menuCardRect.x + Globals.menuCardRect.width > toast.toastLeftEdge
        readonly property real menuDrop: toast.menuInWay ? Globals.menuCardRect.y + Globals.menuCardRect.height + Globals.hyprGaps - Globals.marginsTop : 0

        anchors {
            top: true
            right: true
        }
        margins {
            top: Globals.marginsTop + Math.max(toast.barDrop, toast.menuDrop)
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
            spacing: 8

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

                    // the persistent low-battery warning never auto-dismisses -> only a click or charging clears it
                    readonly property bool persistent: card.modelData.expireTimeout === 0 || (card.modelData.appName === "Battery" && card.modelData.urgency === NotificationUrgency.Critical)

                    // battery alerts: amber at 20%, red at 10% -> heading + a forced 1px border share this colour
                    readonly property bool isBattery: card.modelData.appName === "Battery"
                    readonly property color headingColor: card.isBattery ? (card.modelData.urgency === NotificationUrgency.Critical ? Globals.criticalColor : Globals.warningColor) : Globals.fgColor

                    Timer {
                        running: !card.persistent
                        interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout * 1000 : (card.modelData.urgency === NotificationUrgency.Critical ? 15000 : 5000)
                        onTriggered: card.modelData.expire()
                    }

                    Rectangle {
                        id: cardRect
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                        }
                        height: parent.Layout.preferredHeight
                        implicitHeight: cardLayout.implicitHeight + 28
                        radius: Globals.radius
                        color: Globals.bgColor
                        // battery alerts always carry a 1px border in their heading colour, even when borders are otherwise off
                        border.width: card.isBattery || card.modelData.urgency === NotificationUrgency.Critical ? 1 : Globals.borderWidth
                        border.color: card.isBattery ? card.headingColor : (card.modelData.urgency === NotificationUrgency.Critical ? Globals.criticalColor : Globals.fgColor)
                        layer.enabled: true // should stop screen smeer on resize

                        // arrive from the edge the column is pinned to; a toast is occasional, so it earns a little motion
                        property bool shown: false
                        Component.onCompleted: shown = true
                        opacity: shown ? 1 : 0
                        transform: Translate {
                            x: cardRect.shown ? 0 : 24
                            Behavior on x {
                                NumberAnimation {
                                    duration: 260
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Globals.easeOut
                                }
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }
                        }

                        ColumnLayout {
                            id: cardLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 14
                            }
                            spacing: 4

                            Text {
                                Layout.fillWidth: true
                                visible: card.modelData.appName !== ""
                                text: card.modelData.appName
                                textFormat: Text.PlainText
                                color: Qt.alpha(Globals.fgColor, 0.45)
                                font.family: Globals.textFont.family
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                textFormat: Text.PlainText
                                color: card.headingColor
                                font.family: Globals.textFont.family
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.body
                                textFormat: Text.PlainText
                                color: Qt.alpha(Globals.fgColor, 0.7)
                                font.family: Globals.textFont.family
                                font.pixelSize: 13
                                lineHeight: 1.15
                                wrapMode: Text.WordWrap
                                maximumLineCount: 6
                                elide: Text.ElideRight
                                visible: card.modelData.body !== ""
                            }
                            Flow {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                visible: card.modelData.actions.length > 0
                                spacing: 6
                                Repeater {
                                    model: card.modelData.actions
                                    delegate: MenuButton {
                                        required property var modelData
                                        text: modelData.text || "Open"
                                        onClicked: modelData.invoke()
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: -1
                            onClicked: {
                                const action = card.modelData.actions.find(a => a.identifier === "default");
                                if (action)
                                    action.invoke();
                                else
                                    card.modelData.dismiss();
                            }
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
        }
    }

    // notification center
    PopupWindow {
        open: root.centerOpen
        onDismissed: root.centerOpen = false
        hAlign: "right"
        screen: Globals.focusedScreen // open the center on the focused monitor
        padding: 16
        backgroundColor: Globals.bgColor

        // ~~~ the right island is the only bar element above a right-aligned card -> ride to the top when it's gone ~~~
        margins {
            top: Globals.marginsTop + (Globals.barShown && Globals.rightIslandShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
        }

        ColumnLayout {
            id: centerCol
            width: 348
            spacing: 16

            MenuHeader {
                title: "Notifications"
                icon: "bell"
                actionText: "Clear all"
                actionDestructive: true
                actionEnabled: history.count > 0
                onActionClicked: history.clear()
                onCloseRequested: root.centerOpen = false
            }

            Text {
                visible: history.count === 0
                Layout.fillWidth: true
                Layout.leftMargin: 10
                text: "You're all caught up"
                color: Qt.alpha(Globals.fgColor, 0.5)
                font.family: Globals.textFont.family
                font.pixelSize: 13
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: history.count > 0
                spacing: 4

                Repeater {
                    model: history
                    delegate: Item {
                        // the wrapper drives the layout; the row inside is clipped while removing so it collapses smoothly on dismiss
                        id: delegateWrapper
                        required property int index
                        required property string summary
                        required property string body
                        required property string appName
                        required property int urgency
                        required property string time
                        property bool removing: false
                        Layout.fillWidth: true
                        Layout.preferredHeight: removing ? 0 : inner.implicitHeight

                        clip: removing
                        opacity: removing ? 0 : 1

                        Behavior on Layout.preferredHeight {
                            NumberAnimation {
                                duration: Globals.animDuration
                                easing.type: Easing.BezierSpline
                                easing.bezierCurve: Globals.easeOut
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: Globals.animFast
                            }
                        }

                        HoverHandler {
                            id: rowHover
                        }

                        Rectangle {
                            id: inner
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                            }
                            height: parent.Layout.preferredHeight
                            implicitHeight: historyLayout.implicitHeight + 20
                            radius: 9
                            color: Qt.alpha(Globals.fgColor, rowHover.hovered ? 0.04 : 0)

                            ColumnLayout {
                                id: historyLayout
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    top: parent.top
                                    leftMargin: 10
                                    rightMargin: 6
                                    topMargin: 10
                                }
                                spacing: 4

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Text {
                                        Layout.fillWidth: true
                                        text: delegateWrapper.appName !== "" ? delegateWrapper.appName : "Notification"
                                        textFormat: Text.PlainText
                                        color: Qt.alpha(Globals.fgColor, 0.45)
                                        font.family: Globals.textFont.family
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: delegateWrapper.time
                                        color: Qt.alpha(Globals.fgColor, 0.45)
                                        font.family: Globals.textFont.family
                                        font.pixelSize: 12
                                    }

                                    // dismiss surfaces on hover so a quiet list stays quiet
                                    MenuButton {
                                        icon: "close"
                                        opacity: rowHover.hovered ? 1 : 0
                                        Layout.preferredHeight: 22
                                        Layout.preferredWidth: 22
                                        onClicked: {
                                            // animate out first, then remove
                                            delegateWrapper.removing = true;
                                            removeTimer.start();
                                        }
                                    }

                                    Timer {
                                        id: removeTimer
                                        interval: Globals.animDuration + 30
                                        onTriggered: history.remove(delegateWrapper.index)
                                    }
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.rightMargin: 4
                                    text: delegateWrapper.summary
                                    textFormat: Text.PlainText
                                    // keep battery headings coloured in the history list too
                                    color: delegateWrapper.appName === "Battery" ? (delegateWrapper.urgency === NotificationUrgency.Critical ? Globals.criticalColor : Globals.warningColor) : Globals.fgColor
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    elide: Text.ElideRight
                                }

                                Text {
                                    Layout.fillWidth: true
                                    Layout.rightMargin: 4
                                    visible: delegateWrapper.body !== ""
                                    text: delegateWrapper.body
                                    textFormat: Text.PlainText
                                    color: Qt.alpha(Globals.fgColor, 0.7)
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 13
                                    lineHeight: 1.15
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                    maximumLineCount: 6
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
