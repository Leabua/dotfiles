import Quickshell
import QtQuick
import qs.templates

// click to add the date
BarButton {
    id: root
    property bool showDate: false

    onClicked: showDate = !showDate

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    BarValue {
        text: Qt.formatDateTime(clock.date, root.showDate ? "ddd d MMM  hh:mm" : "hh:mm")
    }
}
