pragma ComponentBehavior: Bound

import qs.menus.engineRoom
import qs.templates

import QtQuick
import QtQuick.Layouts

// battery card (an M3 filled card): charge as a display number over a wavy line, then the readings.
// The Engine Room shows every reading; the compact form in the power menu keeps only "how long have I got"
Rectangle {
    id: root

    property bool compact: false
    property int columns: compact ? 2 : 4
    readonly property int pad: 16

    Layout.fillWidth: true
    implicitHeight: body.implicitHeight + root.pad * 2
    visible: BatteryStats.batReady
    radius: Globals.shapeLargeIncreased
    color: Globals.surfaceContainerHigh

    ColumnLayout {
        id: body
        anchors.fill: parent
        anchors.margins: root.pad
        spacing: root.compact ? 12 : 16

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            MenuIcon {
                name: "battery"
                color: Globals.surfaceVariantContent
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }

            Text {
                text: "Battery"
                color: Globals.surfaceVariantContent
                font: Globals.titleSmall
            }

            // state as an M3 assist chip -> charging reads in the primary container
            Rectangle {
                implicitWidth: stateText.implicitWidth + 20
                implicitHeight: 24
                radius: Globals.shapeSmall
                color: BatteryStats.charging ? Globals.primaryContainer : "transparent"
                border.width: BatteryStats.charging ? 0 : 1
                border.color: Globals.outlineVariant

                Text {
                    id: stateText
                    anchors.centerIn: parent
                    text: BatteryStats.stateStr()
                    color: BatteryStats.charging ? Globals.primaryContainerContent : Globals.surfaceVariantContent
                    font: Globals.labelMedium
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 2

                Text {
                    text: BatteryStats.batPercent
                    color: Globals.surfaceContent
                    font: Globals.headlineSmall
                }
                Text {
                    text: "%"
                    color: Globals.surfaceVariantContent
                    font: Globals.labelLarge
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 3
                }
            }
        }

        WavyProgress {
            Layout.fillWidth: true
            value: BatteryStats.batFrac
            color: BatteryStats.batColor()
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
                        color: Globals.surfaceVariantContent
                        font: Globals.labelSmall
                        elide: Text.ElideRight
                    }

                    Text {
                        Layout.fillWidth: true
                        text: batteryStat.modelData.value
                        color: Globals.surfaceContent
                        font: Globals.titleSmall
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }
}
