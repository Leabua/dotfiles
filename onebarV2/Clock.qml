import Quickshell
import QtQuick

Item {
    id: timeTeller
    property color bgColor: "#1e1e1e"
    property color fgColor: "#FFFFFF"
    property font textFont

    implicitHeight: textID.implicitHeight
    implicitWidth: textID.implicitWidth
    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: textID
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: timeTeller.fgColor
        font: timeTeller.textFont
    }
}
