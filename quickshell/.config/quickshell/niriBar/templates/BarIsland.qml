import QtQuick
import QtQuick.Layouts
import qs.templates

// the rail: one floating surface-container column with fully round ends. Items are 40px pills inset
// railPadding from every edge, so their corners sit concentric inside the round ends
Rectangle {
    id: root

    default property alias content: column.data

    implicitWidth: Globals.railWidth
    implicitHeight: column.implicitHeight + Globals.railPadding * 2
    radius: width / 2
    color: Globals.surfaceContainer

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Globals.railGap
    }
}
