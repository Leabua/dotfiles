pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.defaults

ColumnLayout {
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

    signal toggleExpand
    signal connectRequested
    signal disconnectRequested
    signal forgetRequested
    signal focusField(string field)
    signal toggleReveal

    // signal-bar glyph; secured networks use the lock-overlay variants
    function signalGlyph(): int {
        if (root.signalStrength < 0)
            return 0xF092F; // wifi-strength-outline (saved, out of range)
        const lvl = root.signalStrength > 80 ? 4 : root.signalStrength > 55 ? 3 : root.signalStrength > 30 ? 2 : 1;
        if (root.secured)
            return [0, 0xF0920, 0xF0923, 0xF0926, 0xF0929][lvl]; // wifi-strength-N-lock
        return [0, 0xF091F, 0xF0922, 0xF0925, 0xF0928][lvl];     // wifi-strength-N
    }

    Layout.fillWidth: true
    spacing: Globals.spacing

    // ----- header row -----
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: headerRow.implicitHeight + Globals.spacing
        radius: Globals.radius
        color: root.expanded ? Qt.alpha(Globals.fgColor, 0.12) : (headerArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.1) : "transparent")

        Behavior on color {
            ColorAnimation {
                duration: Globals.animFast
            }
        }

        RowLayout {
            id: headerRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Globals.spacing
            anchors.rightMargin: Globals.spacing
            spacing: Globals.spacing

            // signal icon, filled box when connected (mirrors BtDeviceRow)
            Rectangle {
                implicitWidth: glyph.implicitHeight + Globals.spacing * 2
                implicitHeight: glyph.implicitHeight + Globals.spacing * 2
                radius: Globals.radius
                color: root.connected ? Globals.fgColor : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Globals.animFast
                    }
                }

                Text {
                    id: glyph
                    anchors.centerIn: parent
                    text: String.fromCodePoint(root.signalGlyph())
                    color: root.connected ? Globals.bgColor : Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize + 2
                    font.weight: Globals.textFont.weight
                }
            }

            Text {
                Layout.fillWidth: true
                text: root.ssid === "" ? "Hidden network" : root.ssid
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight
                elide: Text.ElideRight
            }

            // enterprise tag so eduroam-style nets read clearly before expanding
            Text {
                visible: root.enterprise && !root.busy
                text: "802.1X"
                color: Qt.alpha(Globals.fgColor, 0.5)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 4
                font.weight: Globals.textFont.weight
            }

            // connected marker
            Text {
                visible: root.connected && !root.busy
                text: "Connected"
                color: Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize - 3
                font.weight: Globals.textFont.weight
            }

            // busy spinner while connecting
            Text {
                visible: root.busy
                text: String.fromCodePoint(0xF06B0) // sync
                color: Qt.alpha(Globals.fgColor, 0.7)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight

                RotationAnimation on rotation {
                    running: root.busy
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                }
            }
        }

        MouseArea {
            id: headerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggleExpand()
        }
    }

    // ----- expanded action / connect form (excluded from layout when collapsed) -----
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Globals.spacing
        Layout.rightMargin: Globals.spacing
        visible: root.expanded
        spacing: Globals.spacing

        // username (enterprise only) + password, for NEW secured networks; saved
        // networks already hold their credentials so they show no fields
        InputField {
            id: userField
            visible: !root.known && root.secured && root.enterprise
            icon: 0xF0004 // account
            placeholder: "Username (e.g. you@eduroam)"
            value: root.usernameText
            focused: root.focusedField === "username"
            onTapped: root.focusField("username")
        }
        InputField {
            id: passField
            visible: !root.known && root.secured
            icon: 0xF033E // lock
            placeholder: "Password"
            value: root.passwordText
            masked: !root.revealPassword
            focused: root.focusedField === "password"
            showReveal: true
            revealed: root.revealPassword
            onTapped: root.focusField("password")
            onToggleRevealTapped: root.toggleReveal()
        }

        // action buttons
        RowLayout {
            Layout.fillWidth: true
            spacing: Globals.spacing

            PillButton {
                visible: !root.connected && !root.busy
                label: "Connect"
                primary: true
                onTapped: root.connectRequested()
            }
            PillButton {
                visible: root.connected && !root.busy
                label: "Disconnect"
                onTapped: root.disconnectRequested()
            }

            Item {
                Layout.fillWidth: true
            }

            PillButton {
                visible: root.known && !root.busy
                label: "Forget"
                danger: true
                onTapped: root.forgetRequested()
            }
            PillButton {
                visible: !root.known && !root.busy
                label: "Cancel"
                onTapped: root.toggleExpand()
            }
        }
    }

    // ----- inline component: compact pill button -----
    component PillButton: Rectangle {
        id: pill
        property string label: ""
        property bool primary: false
        property bool danger: false
        signal tapped

        implicitWidth: pillText.implicitWidth + Globals.spacing * 3
        implicitHeight: pillText.implicitHeight + Globals.spacing
        radius: Globals.radius
        color: pill.primary ? (pillArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.85) : Globals.fgColor) : (pillArea.containsMouse ? Qt.alpha(pill.danger ? Globals.criticalColor : Globals.fgColor, 0.18) : Qt.alpha(Globals.fgColor, 0.07))

        Behavior on color {
            ColorAnimation {
                duration: Globals.animFast
            }
        }

        Text {
            id: pillText
            anchors.centerIn: parent
            text: pill.label
            color: pill.primary ? Globals.bgColor : (pill.danger ? Globals.criticalColor : Globals.fgColor)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 1
            font.weight: Globals.textFont.weight
        }

        MouseArea {
            id: pillArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: pill.tapped()
        }
    }

    // ----- inline component: focus-driven text field (no Qt TextField; WifiView
    // owns the keystrokes and feeds `value` back in) -----
    component InputField: Rectangle {
        id: field
        property int icon: 0xF033E
        property string placeholder: ""
        property string value: ""
        property bool masked: false
        property bool focused: false
        property bool showReveal: false
        property bool revealed: false
        signal tapped
        signal toggleRevealTapped

        readonly property string shown: field.value.length === 0 ? field.placeholder : (field.masked ? "•".repeat(field.value.length) : field.value)

        Layout.fillWidth: true
        implicitHeight: fieldRow.implicitHeight + Globals.spacing
        radius: Globals.radius
        color: Qt.alpha(Globals.fgColor, field.focused ? 0.14 : 0.07)

        Behavior on color {
            ColorAnimation {
                duration: Globals.animFast
            }
        }

        // full-field tap target sits below the row so the eye toggle can sit on top
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: field.tapped()
        }

        RowLayout {
            id: fieldRow
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Globals.spacing
            anchors.rightMargin: Globals.spacing
            spacing: Globals.spacing

            Text {
                text: String.fromCodePoint(field.icon)
                color: Qt.alpha(Globals.fgColor, 0.7)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: valueText.implicitHeight

                Text {
                    id: valueText
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: field.shown
                    color: field.value.length === 0 ? Qt.alpha(Globals.fgColor, 0.4) : Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: Globals.textFont.pixelSize
                    font.weight: Globals.textFont.weight
                    elide: Text.ElideRight
                }

                // blinking caret riding the end of the text (matches SearchInput)
                Rectangle {
                    width: 2
                    height: Globals.textFont.pixelSize + 2
                    color: Globals.fgColor
                    visible: field.focused
                    anchors.verticalCenter: parent.verticalCenter
                    x: field.value.length === 0 ? valueText.x : valueText.x + valueText.contentWidth + 2

                    SequentialAnimation on opacity {
                        running: field.focused
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

            // reveal-password eye toggle (password field only)
            Text {
                visible: field.showReveal
                text: String.fromCodePoint(field.revealed ? 0xF0209 : 0xF0208) // eye-off / eye
                color: revealArea.containsMouse ? Globals.fgColor : Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight

                MouseArea {
                    id: revealArea
                    anchors.fill: parent
                    anchors.margins: -Globals.spacing / 2
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: field.toggleRevealTapped()
                }
            }
        }
    }
}
