import QtQuick
import QtQuick.Layouts
import qs.templates

Rectangle {
    id: root

    // pure vibecoding -> no bt devices on hand so I should probably test this at some point todo
    property string deviceName: ""
    property string iconName: ""        // BlueZ freedesktop icon name (e.g. "audio-headset")
    property bool connected: false
    property bool busy: false           // pairing / connecting in flight
    property bool batteryAvailable: false
    property real battery: 0            // 0..1
    property bool showForget: false     // paired rows expose an unpair/forget button

    signal activated
    signal forgetRequested

    function glyphFor(name: string): int {
        const s = (name || "").toLowerCase();
        if (s.includes("headset") || s.includes("headphone"))
            return 0xF02CB; // headphones
        if (s.includes("mouse"))
            return 0xF037D;
        if (s.includes("keyboard"))
            return 0xF030C;
        if (s.includes("phone"))
            return 0xF011C;
        if (s.includes("computer") || s.includes("laptop"))
            return 0xF0322;
        if (s.includes("watch"))
            return 0xF0B3C;
        if (s.includes("gamepad") || s.includes("joystick") || s.includes("controller"))
            return 0xF0EB5;
        if (s.includes("audio") || s.includes("speaker"))
            return 0xF04C3;
        return 0xF00AF; // generic bluetooth
    }

    Layout.fillWidth: true
    implicitHeight: row.implicitHeight + Globals.spacing
    radius: Globals.radius
    color: area.containsMouse ? Qt.alpha(Globals.fgColor, 0.1) : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Globals.animFast
        }
    }

    RowLayout {
        id: row
        z: 1 // sit above `area` so the forget button can take its own clicks
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: Globals.spacing
        anchors.rightMargin: Globals.spacing
        spacing: Globals.spacing

        // device-type icon, tinted brighter when connected
        Rectangle {
            implicitWidth: Globals.barIconSize + Globals.spacing * 2
            implicitHeight: Globals.barIconSize + Globals.spacing * 2
            radius: Globals.radius
            color: root.connected ? Globals.fgColor : "transparent"
            // border.width: 1
            border.color: Qt.alpha(Globals.fgColor, 0.3)

            Behavior on color {
                ColorAnimation {
                    duration: Globals.animFast
                }
            }

            Text {
                id: glyph
                anchors.centerIn: parent
                text: String.fromCodePoint(root.glyphFor(root.iconName))
                color: root.connected ? Globals.bgColor : Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: Globals.barIconSize
                font.weight: Globals.textFont.weight
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.deviceName === "" ? "Unknown device" : root.deviceName
            color: Globals.fgColor
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize
            font.weight: Globals.textFont.weight
            elide: Text.ElideRight
        }

        // battery % for connected devices that report it
        Text {
            visible: root.connected && root.batteryAvailable
            text: Math.round(root.battery * 100) + "%"
            color: Qt.alpha(Globals.fgColor, 0.7)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize - 2
            font.weight: Globals.textFont.weight
        }

        // busy spinner-ish glyph while pairing / connecting
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

        // unpair / forget (paired rows only); takes its own clicks so it doesn't
        // also fire the row's connect/disconnect
        Rectangle {
            visible: root.showForget && !root.busy
            implicitWidth: forgetGlyph.implicitWidth + Globals.spacing
            implicitHeight: forgetGlyph.implicitHeight + Globals.spacing
            radius: Globals.radius
            color: forgetArea.containsMouse ? Qt.alpha(Globals.criticalColor, 0.2) : "transparent"

            Behavior on color {
                ColorAnimation {
                    duration: Globals.animFast
                }
            }

            Text {
                id: forgetGlyph
                anchors.centerIn: parent
                text: String.fromCodePoint(0xF0A7A) // trash-can-outline
                color: forgetArea.containsMouse ? Globals.criticalColor : Qt.alpha(Globals.fgColor, 0.6)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight
            }

            MouseArea {
                id: forgetArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.forgetRequested()
            }
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}
