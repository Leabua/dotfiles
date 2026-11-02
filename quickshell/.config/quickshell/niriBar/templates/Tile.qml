import QtQuick
import QtQuick.Layouts
import qs.templates

// an M3 filled card nested inside a menu card: surface-container-high, large-increased corners (20, which
// sits concentric inside the menu's 28 once the menu's padding is taken out), 16px inside
Rectangle {
    id: root

    default property alias content: body.data
    property int pad: 16
    property alias spacing: body.spacing

    implicitWidth: body.implicitWidth + pad * 2
    implicitHeight: body.implicitHeight + pad * 2
    radius: Globals.shapeLargeIncreased
    color: Globals.surfaceContainerHigh

    // top-aligned -> tiles stretched to a shared row height keep their content lined up across the row
    ColumnLayout {
        id: body
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: root.pad
        spacing: 16
    }
}
