import QtQuick
import QtQuick.Layouts
import qs.templates

Rectangle {
    Layout.fillWidth: true
    // keeps the divider regardless of if we go Globals.border = 0 or not
    Layout.preferredHeight: Globals.borderWidth === 0 ? 1 : Globals.borderWidth
    radius: Globals.borderWidth
    color: Qt.alpha(Globals.fgColor, 0.3)
}
