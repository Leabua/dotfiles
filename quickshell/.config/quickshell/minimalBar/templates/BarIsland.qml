import QtQuick
import QtQuick.Layouts
import qs.templates

// one rounded island of the bar; its entries are BarButton pills, inset barIslandInset top / bottom so the radii nest
Rectangle {
    id: root

    default property alias content: row.data
    // Match the vertical inset so an end button's corners are concentric with
    // the island. Plain content (OSDs) supplies its roomier padding explicitly.
    property int padding: Globals.barIslandInset

    // an island whose entries are all hidden (left island between OSDs) takes no space at all
    visible: row.implicitWidth > 0
    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Globals.barIslandHeight
    radius: Globals.barIslandRadius
    color: Globals.bgColor

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0
    }
}
