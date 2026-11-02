import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.templates

ColumnLayout {
    id: root

    property string iconName: "speaker"
    property string label: ""
    property string iconSource: ""
    property real value: 0
    property bool muted: false
    readonly property string displayIcon: {
        if (root.muted || root.value <= 0)
            return root.iconName + "Muted";
        if (root.iconName === "speaker")
            return root.value < 0.34 ? "speakerLow" : root.value < 0.67 ? "speakerMedium" : "speaker";
        return root.iconName;
    }
    signal moved(real v)
    signal iconClicked

    Layout.fillWidth: true
    spacing: 4

    Text {
        Layout.fillWidth: true
        Layout.leftMargin: 56 // under the device / app name, past the icon column
        visible: root.label !== ""
        text: root.label
        textFormat: Text.PlainText
        color: Globals.surfaceVariantContent
        font: Globals.bodyMedium
        elide: Text.ElideRight
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 4
        Layout.rightMargin: 4
        spacing: 12

        // the device / app icon doubles as the mute button
        MenuButton {
            icon: appIcon.status === Image.Ready ? "" : root.displayIcon
            onClicked: root.iconClicked()

            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 22
                height: 22
                source: root.iconSource
                sourceSize.width: 44
                sourceSize.height: 44
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: status === Image.Ready
                opacity: root.muted ? 0.38 : 1
            }
        }

        M3Slider {
            Layout.fillWidth: true
            from: 0
            to: 1
            stepSize: 0.01
            dimmed: root.muted
            value: Math.max(0, Math.min(1, root.value))
            onMoved: root.moved(value)
        }

        Text {
            Layout.preferredWidth: 44
            text: root.muted ? "Muted" : Math.round(root.value * 100) + "%"
            color: Globals.surfaceVariantContent
            horizontalAlignment: Text.AlignRight
            font: Globals.labelLarge
        }
    }
}
