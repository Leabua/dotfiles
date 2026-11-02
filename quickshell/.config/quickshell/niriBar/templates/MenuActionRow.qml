import QtQuick
import QtQuick.Layouts
import qs.templates

// M3 list item: 52px, leading icon, label. The current choice sits on a secondary-container pill with a
// check; hover / keyboard selection lay an on-surface state layer over it. Destructive rows turn error on hover
Rectangle {
    id: row

    property string text: ""
    property string icon: ""
    property bool active: false
    property bool selected: false
    property bool destructive: false
    signal clicked
    signal hovered

    readonly property bool danger: destructive && (mouse.containsMouse || selected)
    readonly property color content: danger ? Globals.error : active ? Globals.secondaryContainerContent : Globals.surfaceContent

    Layout.fillWidth: true
    implicitHeight: 52
    radius: active ? height / 2 : Globals.shapeLarge
    activeFocusOnTab: true
    opacity: enabled ? 1 : 0.38
    color: active ? Globals.secondaryContainer : "transparent"
    Behavior on radius {
        NumberAnimation {
            duration: Globals.animDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()
    scale: mouse.pressed ? 0.98 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }

    // state layer
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: row.danger ? Globals.error : row.content
        opacity: mouse.pressed ? Globals.statePressed : row.selected || row.activeFocus ? Globals.stateFocus : mouse.containsMouse ? Globals.stateHover : 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 14

        MenuIcon {
            visible: Globals.buttonIcons && row.icon !== ""
            Layout.preferredWidth: 22
            Layout.preferredHeight: 22
            name: row.icon
            color: row.danger ? Globals.error : row.active ? Globals.secondaryContainerContent : Globals.surfaceVariantContent
        }

        Text {
            Layout.fillWidth: true
            text: row.text
            color: row.content
            font: Globals.bodyLarge
            elide: Text.ElideRight
        }

        MenuIcon {
            visible: row.active
            name: "check"
            color: Globals.secondaryContainerContent
            strokeWidth: 2
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: row.hovered()
        onClicked: row.clicked()
    }
}
