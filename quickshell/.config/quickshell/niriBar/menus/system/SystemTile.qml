import QtQuick
import QtQuick.Layouts
import qs.templates

// one cell of the system menu's quick row: icon + label, current state beneath. A tile that opens another menu
// carries a chevron; a toggle tile that's on fills with primary-container and morphs its corners to a full pill
Rectangle {
    id: tile

    property string text: ""
    property string icon: ""
    property string detail: ""
    property bool opensMenu: false
    property bool active: false
    signal clicked

    readonly property color content: active ? Globals.primaryContainerContent : Globals.surfaceContent

    Layout.fillWidth: true
    Layout.preferredWidth: 1 // equal columns whatever the labels
    implicitHeight: 72
    radius: active ? height / 2 : Globals.shapeLargeIncreased
    activeFocusOnTab: true
    color: active ? Globals.primaryContainer : Globals.surfaceContainerHigh
    Keys.onSpacePressed: clicked()
    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    Behavior on radius {
        NumberAnimation {
            duration: Globals.animEnter
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeSpatial
        }
    }
    Behavior on color {
        ColorAnimation {
            duration: Globals.animDuration
        }
    }
    scale: mouse.pressed ? 0.97 : 1
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
        color: tile.content
        opacity: mouse.pressed ? Globals.statePressed : mouse.containsMouse ? Globals.stateHover : tile.activeFocus ? Globals.stateFocus : 0
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 20
        anchors.rightMargin: 16
        spacing: 14

        MenuIcon {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            name: tile.icon
            color: tile.active ? Globals.primaryContainerContent : Globals.surfaceVariantContent
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: tile.text
                color: tile.content
                font: Globals.titleSmall
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: tile.detail !== ""
                text: tile.detail
                color: tile.active ? Globals.primaryContainerContent : Globals.surfaceVariantContent
                opacity: tile.active ? 0.8 : 1
                font: Globals.bodySmall
                elide: Text.ElideRight
            }
        }

        MenuIcon {
            visible: tile.opensMenu
            name: "chevronRight"
            color: Globals.surfaceVariantContent
            Layout.preferredWidth: 18
            Layout.preferredHeight: 18
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.clicked()
    }
}
