import QtQuick
import QtQuick.Layouts
import qs.templates

// one engine room reading: icon + label, the value as an M3 display number, and a wavy progress line
// tinted by load (primary while calm, amber then error as it climbs)
ColumnLayout {
    id: meter

    property string label: ""
    property string detail: ""
    property string icon: "cpu"
    property real value: 0
    property bool available: true
    property color accent: Globals.primary
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        MenuIcon {
            name: meter.icon
            color: Globals.surfaceVariantContent
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
        }

        Text {
            Layout.fillWidth: true
            text: meter.label
            color: Globals.surfaceVariantContent
            font: Globals.titleSmall
        }

        Text {
            visible: meter.detail !== ""
            text: meter.detail
            color: Globals.surfaceVariantContent
            opacity: 0.7
            font: Globals.labelSmall
        }
    }

    RowLayout {
        spacing: 2

        Text {
            text: meter.available ? Math.round(meter.value * 100) : "—"
            color: Globals.surfaceContent
            font: Globals.displaySmall
        }

        Text {
            visible: meter.available
            text: "%"
            color: Globals.surfaceVariantContent
            font: Globals.titleMedium
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 6
        }
    }

    WavyProgress {
        Layout.fillWidth: true
        value: meter.available ? meter.value : 0
        color: meter.accent
    }
}
