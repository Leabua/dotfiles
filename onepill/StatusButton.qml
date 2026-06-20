import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool isActive: true
    property bool invertWhenOff: false
    property color fgColor: "#FFFFFF"
    property color bgColor: "transparent"
    property font textFont
    property bool isInteractive: true

    signal clicked()

    implicitWidth: row.implicitWidth + 10
    implicitHeight: 24
    radius: height / 2
    color: (invertWhenOff && !isActive) ? fgColor : bgColor

    // subtle hover effect
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "#ffffff"
        opacity: (root.isInteractive && hoverHandler.hovered) ? 0.1 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: root.icon
            font: root.textFont
            color: (root.invertWhenOff && !root.isActive) ? root.bgColor : root.fgColor
            visible: root.icon !== ""
        }

        Text {
            text: root.label
            font: root.textFont
            color: (root.invertWhenOff && !root.isActive) ? root.bgColor : root.fgColor
            visible: root.label !== ""
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.isInteractive
    }

    TapHandler {
        enabled: root.isInteractive
        onTapped: root.clicked()
    }
}
