import QtQuick
import QtQuick.Layouts
import qs.templates

// one rounded island of the bar; its entries are BarButton pills inset by barIslandInset so the two radii nest
Rectangle {
    id: root

    default property alias content: row.data
    property int padding: Globals.barIslandInset // islands holding plain content (the OSDs) pad out to the pills' text inset

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
