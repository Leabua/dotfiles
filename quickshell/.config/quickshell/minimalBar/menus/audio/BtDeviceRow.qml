import QtQuick
import QtQuick.Layouts
import qs.templates

Rectangle {
    id: root

    property string deviceName: ""
    property string iconName: ""
    property bool connected: false
    property bool busy: false
    property string statusText: busy ? "Connecting…" : connected ? "Connected" : "Not connected"
    property bool batteryAvailable: false
    property real battery: 0
    property bool showForget: false

    signal activated
    signal forgetRequested

    function iconFor(name: string): string {
        const value = (name || "").toLowerCase();
        if (value.includes("headset") || value.includes("headphone"))
            return "headphones";
        if (value.includes("mouse"))
            return "mouse";
        if (value.includes("keyboard"))
            return "keyboard";
        if (value.includes("phone"))
            return "phone";
        if (value.includes("computer") || value.includes("laptop"))
            return "computer";
        if (value.includes("watch"))
            return "watch";
        if (value.includes("gamepad") || value.includes("joystick") || value.includes("controller"))
            return "controller";
        if (value.includes("audio") || value.includes("speaker"))
            return "speaker";
        return "bluetooth";
    }

    Layout.fillWidth: true
    implicitHeight: 54
    radius: 9
    activeFocusOnTab: true
    color: Qt.alpha(Globals.fgColor, activeFocus ? 0.1 : connected ? 0.06 : area.containsMouse ? 0.04 : 0)
    Keys.onSpacePressed: if (!busy) activated()
    Keys.onReturnPressed: if (!busy) activated()
    scale: area.pressed ? 0.985 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.OutCubic
        }
    }

    RowLayout {
        z: 1
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 6
        spacing: 10

        MenuIcon {
            name: root.iconFor(root.iconName)
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            color: Qt.alpha(Globals.fgColor, root.connected ? 0.9 : 0.55)
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: root.deviceName === "" ? "Unknown device" : root.deviceName
                textFormat: Text.PlainText
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: 14
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.statusText
                color: Qt.alpha(Globals.fgColor, 0.45)
                font.family: Globals.textFont.family
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.connected && root.batteryAvailable
            text: Math.round(root.battery * 100) + "%"
            color: Qt.alpha(Globals.fgColor, 0.55)
            font.family: Globals.textFont.family
            font.pixelSize: 12
        }

        MenuButton {
            visible: root.showForget
            enabled: !root.busy
            icon: "trash"
            destructive: true
            onClicked: root.forgetRequested()
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        enabled: !root.busy
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
