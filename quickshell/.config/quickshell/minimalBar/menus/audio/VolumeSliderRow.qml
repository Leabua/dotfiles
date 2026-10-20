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
        Layout.leftMargin: 42 // under the device / app name, past the icon column
        visible: root.label !== ""
        text: root.label
        textFormat: Text.PlainText
        color: Qt.alpha(Globals.fgColor, 0.75)
        font.family: Globals.textFont.family
        font.pixelSize: 13
        elide: Text.ElideRight
    }

    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 10
        Layout.rightMargin: 10
        spacing: 10

        MenuButton {
            Layout.preferredWidth: 22
            icon: appIcon.status === Image.Ready ? "" : root.displayIcon
            onClicked: root.iconClicked()

            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 18
                height: 18
                source: root.iconSource
                sourceSize.width: 36
                sourceSize.height: 36
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: status === Image.Ready
                opacity: root.muted ? 0.4 : 1
            }
        }

        Slider {
            id: control
            Layout.fillWidth: true
            implicitHeight: 28
            from: 0
            to: 1
            stepSize: 0.01
            padding: 0
            value: Math.max(0, Math.min(1, root.value))
            onMoved: root.moved(value)

            background: Rectangle {
                x: control.leftPadding
                y: control.topPadding + control.availableHeight / 2 - height / 2
                width: control.availableWidth
                height: 4
                radius: 2
                color: Qt.alpha(Globals.fgColor, 0.12)

                Rectangle {
                    width: control.visualPosition * parent.width
                    height: parent.height
                    radius: parent.radius
                    color: Qt.alpha(Globals.fgColor, root.muted ? 0.35 : 0.9)
                }
            }

            handle: Rectangle {
                x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
                y: control.topPadding + (control.availableHeight - height) / 2
                implicitWidth: 10
                implicitHeight: 10
                radius: 5
                color: Globals.fgColor
                visible: control.hovered || control.pressed || control.activeFocus
            }
        }

        Text {
            Layout.preferredWidth: 40
            text: root.muted ? "Muted" : Math.round(root.value * 100) + "%"
            color: Qt.alpha(Globals.fgColor, 0.55)
            horizontalAlignment: Text.AlignRight
            font.family: Globals.textFont.family
            font.pixelSize: 12
        }
    }
}
