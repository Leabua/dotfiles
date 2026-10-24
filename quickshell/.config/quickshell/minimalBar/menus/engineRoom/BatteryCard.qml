pragma ComponentBehavior: Bound

import qs.menus.engineRoom
import qs.templates

import QtQuick
import QtQuick.Layouts

// Recessed battery panel. The Engine Room shows every reading; the compact
// form in the battery menu keeps only what answers "how long have I got".
Rectangle {
    id: root

    property bool compact: false
    property int columns: compact ? 2 : 4
    readonly property int pad: compact ? 14 : 16

    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + root.pad * 2
    visible: BatteryStats.batReady
    radius: 12
    color: Qt.darker(Globals.bgColor, 1.2)

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: root.pad
        anchors.leftMargin: 10 // shares the menu glyphs' column -> one left edge down the card
        anchors.rightMargin: 10
        spacing: root.compact ? 12 : 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MenuIcon {
                name: "battery"
                color: Qt.alpha(Globals.fgColor, 0.7)
            }

            Text {
                text: "Battery"
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: 14
                font.weight: Font.Medium
            }

            Text {
                Layout.fillWidth: true
                text: BatteryStats.stateStr()
                color: BatteryStats.charging ? Globals.healthy : Qt.alpha(Globals.fgColor, 0.5)
                font.family: Globals.textFont.family
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                text: BatteryStats.batPercent + "%"
                color: Globals.fgColor
                font.family: Globals.textFont.family
                font.pixelSize: 22
                font.weight: Font.Medium
            }
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 4
            radius: 2
            color: Qt.alpha(Globals.fgColor, 0.08)

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, BatteryStats.batFrac))
                height: parent.height
                radius: parent.radius
                color: BatteryStats.batColor()
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.columns
            columnSpacing: 20
            rowSpacing: 16

            Repeater {
                model: {
                    // remaining time leads in the compact form: it's the question a battery click asks
                    const time = { label: BatteryStats.charging ? "Until full" : "Remaining", value: BatteryStats.timeStr() };
                    const rate = { label: BatteryStats.charging ? "Charge rate" : "Discharge rate", value: BatteryStats.rateStr() };
                    if (root.compact)
                        return [time, rate];
                    return [rate, time, { label: "Health", value: BatteryStats.healthStr() }, { label: "Stored energy", value: BatteryStats.energyStr() }];
                }

                delegate: ColumnLayout {
                    id: batteryStat
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    spacing: 7

                    Text {
                        Layout.fillWidth: true
                        text: batteryStat.modelData.label
                        color: Qt.alpha(Globals.fgColor, 0.45)
                        font.family: Globals.textFont.family
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: batteryStat.modelData.value
                        color: Globals.fgColor
                        font.family: Globals.textFont.family
                        font.pixelSize: 14
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
