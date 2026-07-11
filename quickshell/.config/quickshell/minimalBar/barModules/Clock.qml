import Quickshell
import QtQuick
import qs.templates

Item {
    id: root
    property bool showDate: false

    implicitHeight: content.implicitHeight
    implicitWidth: content.implicitWidth

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BarIcon {
        id: content
        displayText: root.showDate ? Qt.formatDateTime(clock.date, "hh:mm - dd MMM") : Qt.formatDateTime(clock.date, "hh:mm")
    }
    MouseArea {
        id: mouse
        anchors.fill: parent
        anchors.margins: -1
        cursorShape: Qt.PointingHandCursor

        //click to show longdate
        onClicked: root.showDate = !root.showDate
    }
}
