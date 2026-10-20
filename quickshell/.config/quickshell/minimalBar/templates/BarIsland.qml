import QtQuick
import QtQuick.Layouts
import qs.templates

// one rounded island of the bar; its entries are BarButton pills, inset barIslandInset top / bottom so the radii nest
Rectangle {
    id: root

    default property alias content: row.data
    property int padding: Globals.barIslandSidePadding // left / right; islands holding plain content (the OSDs) add the pills' text padding

    // an island whose entries are all hidden (left island between OSDs) takes no space at all
    visible: row.implicitWidth > 0
    implicitWidth: row.implicitWidth + padding * 2
    implicitHeight: Globals.barIslandHeight
    radius: height / 2
    color: Globals.bgColor

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 0
    }
}
