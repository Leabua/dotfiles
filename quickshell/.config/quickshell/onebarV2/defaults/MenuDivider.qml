import QtQuick
import QtQuick.Layouts
import qs.defaults

// Thin inset divider for under menu headings. Drop it into a heading's
// ColumnLayout right after the title row: it fills the column width so its left
// edge lines up with the heading icon, and it never reaches the panel edge
// because the card padding already insets the whole column. Menus whose heading
// row carries an extra horizontal margin should pass the same Layout.leftMargin /
// Layout.rightMargin on the divider so the two stay aligned.
Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: Globals.borderWidth
    radius: Globals.borderWidth
    color: Qt.alpha(Globals.fgColor, 0.3)
}
