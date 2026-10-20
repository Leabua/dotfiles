pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.menus.wifi
import qs.templates

// one network: saved ones get the two-line row (mirrors BtDeviceRow), nearby ones a
// tighter single line with a lock; secured nearby networks unfold an inline password form
Rectangle {
    id: root

    property string ssid: ""
    property int signalStrength: -1     // 0..100, -1 when unknown (saved but out of range)
    property bool secured: false
    property bool enterprise: false     // 802.1X (eduroam etc.) -> needs a username too
    property bool known: false          // saved connection (top section) vs new (bottom)
    property bool connected: false
    property bool busy: false           // connect / up in flight

    property bool expanded: false
    // form state lives in WifiView so its keyboard handler can edit it
    property string passwordText: ""
    property string usernameText: ""
    property string focusedField: "password"   // "username" | "password"
    property bool revealPassword: false

    signal activated
    signal forgetRequested
    signal connectRequested
    signal cancelRequested
    signal focusField(string field)
    signal toggleReveal
    signal passwordEdited(string value)
    signal usernameEdited(string value)
    signal keyPressed(var event)

    readonly property bool inRange: signalStrength >= 0
    readonly property int rowHeight: known ? 54 : 44
    readonly property bool canSubmit: passwordText !== "" && (!enterprise || usernameText !== "")
    readonly property string statusText: root.busy ? "Connecting…" : root.connected ? "Connected" : root.inRange ? "Saved" : "Out of range"

    Layout.fillWidth: true
    implicitHeight: root.rowHeight + formClip.height
    radius: 9
    color: Qt.alpha(Globals.fgColor, root.expanded || root.connected ? 0.06 : headerArea.containsMouse ? 0.04 : 0)

    // press feedback: the row gives a little under the pointer
    scale: headerArea.pressed ? 0.985 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }

    // ----- header row -----
    MouseArea {
        id: headerArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.rowHeight
        enabled: !root.busy
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: root.rowHeight
        anchors.leftMargin: 10
        anchors.rightMargin: 6
        spacing: 10
        // saved-but-absent networks recede so the reachable ones lead
        opacity: root.known && !root.inRange && !root.connected ? 0.5 : 1

        WifiSignal {
            strength: root.signalStrength
            sweeping: root.busy
            color: Qt.alpha(Globals.fgColor, root.connected || root.busy ? 1 : 0.8)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: root.ssid === "" ? "Hidden network" : root.ssid
                textFormat: Text.PlainText
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: root.known
                text: root.statusText
                color: Qt.alpha(Globals.fgColor, 0.45)
                font.family: Globals.textFont.family
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        // nearby: connecting note, else a lock when it takes credentials
        Text {
            visible: !root.known && root.busy
            text: "Connecting…"
            color: Qt.alpha(Globals.fgColor, 0.45)
            font.family: Globals.textFont.family
            font.pixelSize: 12
        }
        MenuIcon {
            visible: !root.known && !root.busy && root.secured
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            Layout.rightMargin: 4
            name: "lock"
            color: Qt.alpha(Globals.fgColor, 0.4)
        }

        MenuButton {
            visible: root.known
            enabled: !root.busy
            icon: "trash"
            destructive: true
            onClicked: root.forgetRequested()
        }
    }

    // ----- inline connect form (new secured networks only) -----
    Item {
        id: formClip
        anchors.left: parent.left
        anchors.right: parent.right
        y: root.rowHeight
        height: root.expanded ? form.implicitHeight + 12 : 0
        visible: height > 0
        clip: true
        opacity: root.expanded ? 1 : 0

        // open at a readable pace, close quicker -> the system answering, not deliberating
        Behavior on height {
            NumberAnimation {
                duration: root.expanded ? 220 : 150
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeOut
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: root.expanded ? 180 : 100
                easing.type: Easing.OutCubic
            }
        }

        ColumnLayout {
            id: form
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 42 // under the network name, past the signal fan
            anchors.rightMargin: 10
            spacing: 6

            InputField {
                visible: root.enterprise
                placeholder: "Username"
                value: root.usernameText
                focused: Globals.wifiMenuOpen && root.expanded && root.enterprise && root.focusedField === "username"
                onTapped: root.focusField("username")
                onEdited: value => root.usernameEdited(value)
                onKeyPressed: event => root.keyPressed(event)
            }
            InputField {
                placeholder: "Password"
                value: root.passwordText
                masked: !root.revealPassword
                focused: Globals.wifiMenuOpen && root.expanded && root.focusedField === "password"
                showReveal: true
                revealed: root.revealPassword
                onTapped: root.focusField("password")
                onToggleRevealTapped: root.toggleReveal()
                onEdited: value => root.passwordEdited(value)
                onKeyPressed: event => root.keyPressed(event)
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 6

                Item {
                    Layout.fillWidth: true
                }
                MenuButton {
                    text: "Cancel"
                    onClicked: root.cancelRequested()
                }
                PrimaryButton {
                    text: "Connect"
                    enabled: root.canSubmit
                    onClicked: root.connectRequested()
                }
            }
        }
    }

    // ----- inline component: filled button, same metrics as MenuButton -----
    component PrimaryButton: Rectangle {
        id: primary
        property string text: ""
        signal clicked

        implicitWidth: primaryText.implicitWidth + 20
        implicitHeight: 28
        radius: 7
        opacity: enabled ? 1 : 0.35
        color: Qt.alpha(Globals.fgColor, primaryArea.containsMouse ? 0.85 : 1)
        scale: primaryArea.pressed ? 0.97 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Text {
            id: primaryText
            anchors.centerIn: parent
            text: primary.text
            color: Globals.bgColor
            font.family: Globals.textFont.family
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        MouseArea {
            id: primaryArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: primary.clicked()
        }
    }

    // native fields support pasting credentials and editing in place
    component InputField: Rectangle {
        id: field
        property string placeholder: ""
        property string value: ""
        property bool masked: false
        property bool focused: false
        property bool showReveal: false
        property bool revealed: false
        signal tapped
        signal toggleRevealTapped
        signal edited(string value)
        signal keyPressed(var event)
        onFocusedChanged: {
            if (focused)
                Qt.callLater(nativeInput.forceActiveFocus);
        }

        Layout.fillWidth: true
        implicitHeight: 34
        radius: 7
        color: Qt.alpha(Globals.fgColor, field.focused ? 0.1 : 0.06)
        border.width: 1
        border.color: Qt.alpha(Globals.fgColor, field.focused ? 0.3 : 0)

        // full-field tap target sits below the row so the eye toggle can sit on top
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.IBeamCursor
            onClicked: field.tapped()
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 8
            spacing: 6

            TextField {
                id: nativeInput
                Layout.fillWidth: true
                text: field.value
                placeholderText: field.placeholder
                placeholderTextColor: Qt.alpha(Globals.fgColor, 0.35)
                echoMode: field.masked ? TextInput.Password : TextInput.Normal
                selectByMouse: true
                color: Globals.fgColor
                selectionColor: Globals.fgColor
                selectedTextColor: Globals.bgColor
                font.family: Globals.textFont.family
                font.pixelSize: 13
                font.weight: Font.Medium
                padding: 0
                background: null
                onTextEdited: field.edited(text)
                onActiveFocusChanged: {
                    if (activeFocus)
                        field.tapped();
                }
                Keys.onPressed: event => {
                    event.accepted = false;
                    field.keyPressed(event);
                }
            }

            // reveal-password eye toggle (password field only)
            MenuIcon {
                visible: field.showReveal
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                name: field.revealed ? "eyeOff" : "eye"
                color: Qt.alpha(Globals.fgColor, revealArea.containsMouse ? 0.9 : 0.5)

                MouseArea {
                    id: revealArea
                    anchors.fill: parent
                    anchors.margins: -6
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: field.toggleRevealTapped()
                }
            }
        }
    }
}
