pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import qs.templates

ColumnLayout {
    id: root

    property int icon: 0xF057E
    property var devices: []            // array of PwNode for this direction
    property var currentNode: null      // the active default node (drives the highlight)
    property string currentName: ""     // label for the collapsed header
    property var nameFor: (function (n) {
            return "";
        })                                  // node -> display string, supplied by the owner

    property bool expanded: false

    signal selected(var node)

    Layout.fillWidth: true
    spacing: Globals.spacing

    // collapsed header: [icon] current device name [chevron]
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: headerRow.implicitHeight + Globals.spacing
        radius: Globals.radius
        color: headerArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.1) : "transparent"

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

            Text {
                text: String.fromCodePoint(root.icon)
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize + 6
                font.weight: Globals.textFont.weight
            }

            Text {
                Layout.fillWidth: true
                text: root.currentName === "" ? "No device" : root.currentName
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight
                elide: Text.ElideRight
            }

            // chevron flips up while the list is open
            Text {
                text: String.fromCodePoint(root.expanded ? 0xF0143 : 0xF0140)
                color: Qt.alpha(Globals.fgColor, 0.7)
                font.family: Globals.textFont.family
                font.pixelSize: Globals.textFont.pixelSize
                font.weight: Globals.textFont.weight
            }
        }

        MouseArea {
            id: headerArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // expanded list of selectable devices (excluded from layout when collapsed)
    ColumnLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Globals.spacing
        visible: root.expanded
        spacing: 0

        Repeater {
            model: root.devices

            delegate: Rectangle {
                id: option
                required property var modelData
                readonly property bool active: root.currentNode && modelData && root.currentNode.id === modelData.id

                Layout.fillWidth: true
                implicitHeight: optionText.implicitHeight + Globals.spacing
                radius: Globals.radius
                color: optionArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.1) : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Globals.animFast
                    }
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Globals.spacing
                    anchors.rightMargin: Globals.spacing
                    spacing: Globals.spacing

                    // active marker dot
                    Text {
                        text: String.fromCodePoint(0xF012C) // check
                        opacity: option.active ? 1 : 0
                        color: Globals.fgColor
                        font.family: Globals.textFont.family
                        font.pixelSize: Globals.textFont.pixelSize - 4
                        font.weight: Globals.textFont.weight
                    }

                    Text {
                        id: optionText
                        Layout.fillWidth: true
                        text: root.nameFor(option.modelData)
                        color: option.active ? Globals.fgColor : Qt.alpha(Globals.fgColor, 0.75)
                        font.family: Globals.textFont.family
                        font.pixelSize: Globals.textFont.pixelSize - 1
                        font.weight: Globals.textFont.weight
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: optionArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.selected(option.modelData);
                        root.expanded = false;
                    }
                }
            }
        }
    }
}
