import Quickshell
import QtQuick
import qs

Item {
    id: timeTeller

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: textID
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: Globals.fgColor
        font: Globals.textFont
    }
}
