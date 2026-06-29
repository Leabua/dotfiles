import QtQuick
import QtQuick.Layouts
import qs.defaults

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: Globals.borderWidth === 0 ? 1 : Globals.borderWidth // keeps the divider regardless of if we go Globals.border = 0 or not 
    radius: Globals.borderWidth
    color: Qt.alpha(Globals.fgColor, 0.3)
}
