pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.templates

ColumnLayout {
    id: root

    property string label: ""
    property string iconName: "speaker"
    property var devices: []
    property var currentNode: null
    property string currentName: ""
    property var nameFor: (function (node) { return ""; })
    property bool expanded: false
    readonly property bool canExpand: root.devices.length > 1
    signal selected(var node)

    Layout.fillWidth: true
    spacing: 4
    onCanExpandChanged: if (!canExpand) expanded = false

    Rectangle {
        id: header
        Layout.fillWidth: true
        implicitHeight: 44
        radius: 9
        activeFocusOnTab: root.canExpand
        color: Qt.alpha(Globals.fgColor, activeFocus || (headerMouse.containsMouse && root.canExpand) ? 0.04 : 0)
        Keys.onSpacePressed: root.expanded = !root.expanded
        Keys.onReturnPressed: root.expanded = !root.expanded

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 10

            MenuIcon {
                name: root.iconName
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                color: Qt.alpha(Globals.fgColor, 0.6)
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Text {
                    text: root.label
                    color: Qt.alpha(Globals.fgColor, 0.45)
                    font.family: Globals.textFont.family
                    font.pixelSize: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: root.currentName === "" ? "No device available" : root.currentName
                    textFormat: Text.PlainText
                    color: Globals.fgColor
                    font.family: Globals.textFont.family
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                }
            }

            MenuIcon {
                visible: root.canExpand
                name: root.expanded ? "chevronUp" : "chevronDown"
                color: Qt.alpha(Globals.fgColor, 0.45)
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
            }
        }

        MouseArea {
            id: headerMouse
            anchors.fill: parent
            enabled: root.canExpand
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 32 // option names land under the current device name
        visible: root.expanded
        spacing: 2

        Repeater {
            model: root.devices

            delegate: MenuActionRow {
                required property var modelData
                text: root.nameFor(modelData)
                active: !!root.currentNode && !!modelData && root.currentNode.id === modelData.id
                onClicked: {
                    root.selected(modelData);
                    root.expanded = false;
                }
            }
        }
    }
}
