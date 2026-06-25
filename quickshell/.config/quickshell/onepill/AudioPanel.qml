import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Rectangle {
    id: root

    implicitWidth: 360
    implicitHeight: layout.implicitHeight
    color: "transparent"

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property PwNode defaultSource: Pipewire.defaultAudioSource
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.mediaClass === "Audio/Sink")
    readonly property var sources: Pipewire.nodes.values.filter(n => n.mediaClass === "Audio/Source")

    PwObjectTracker {
        objects: [root.defaultSink, root.defaultSource].concat(root.sinks).concat(root.sources)
    }

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "󰕾 Audio"
            font.family: global.shellFont.family
            font.pixelSize: 15
            font.bold: true
            color: global.fgColor
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.15)
        }

        AudioControl {
            Layout.fillWidth: true
            icon: "󰓃"
            title: "Output"
            node: root.defaultSink
        }

        AudioControl {
            Layout.fillWidth: true
            icon: "󰍬"
            title: "Input"
            node: root.defaultSource
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.15)
        }

        Text {
            text: "Output Devices"
            font.family: global.shellFont.family
            font.pixelSize: 13
            font.bold: true
            color: global.fgColor
            opacity: 0.8
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.sinks
                DeviceRow {
                    Layout.fillWidth: true
                    icon: root.defaultSink && root.defaultSink.id === modelData.id ? "󰓃" : "󰓄"
                    name: modelData.description || modelData.name || "Output"
                    active: root.defaultSink && root.defaultSink.id === modelData.id
                    onClicked: {
                        setDefaultProc.nodeId = modelData.id;
                        setDefaultProc.running = true;
                    }
                }
            }
        }

        Text {
            text: "Input Devices"
            font.family: global.shellFont.family
            font.pixelSize: 13
            font.bold: true
            color: global.fgColor
            opacity: 0.8
            Layout.topMargin: 4
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: root.sources
                DeviceRow {
                    Layout.fillWidth: true
                    icon: root.defaultSource && root.defaultSource.id === modelData.id ? "󰍬" : "󰍭"
                    name: modelData.description || modelData.name || "Input"
                    active: root.defaultSource && root.defaultSource.id === modelData.id
                    onClicked: {
                        setDefaultProc.nodeId = modelData.id;
                        setDefaultProc.running = true;
                    }
                }
            }
        }
    }

    Process {
        id: setDefaultProc
        property int nodeId: 0
        command: ["wpctl", "set-default", nodeId.toString()]
    }

    component AudioControl: Rectangle {
        property string icon: ""
        property string title: ""
        property PwNode node

        implicitHeight: 74
        radius: 12
        color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.05)
        border.color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.15)
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: icon
                    font.family: global.shellFont.family
                    font.pixelSize: 16
                    color: global.fgColor
                }

                Text {
                    text: node ? (node.description || node.name || "Unknown") : "Unavailable"
                    font.family: global.shellFont.family
                    font.pixelSize: 13
                    font.bold: true
                    color: global.fgColor
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                Text {
                    text: node && node.audio ? Math.round(node.audio.volume * 100) + "%" : "--"
                    font.family: global.shellFont.family
                    font.pixelSize: 12
                    font.bold: true
                    color: global.fgColor
                    opacity: 0.8
                }
            }

            Slider {
                Layout.fillWidth: true
                from: 0
                to: 1
                value: node && node.audio ? node.audio.volume : 0
                enabled: node && node.audio
                
                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: parent.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.2)
                    
                    Rectangle {
                        width: parent.parent.visualPosition * parent.width
                        height: parent.height
                        color: global.fgColor
                        radius: 3
                    }
                }
                
                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: global.fgColor
                    border.color: Qt.rgba(0, 0, 0, 0.2)
                    border.width: 1
                }
                
                onValueChanged: {
                    if (pressed && node && node.audio)
                        node.audio.volume = value;
                }
            }
        }
    }

    component DeviceRow: Rectangle {
        signal clicked()
        property string icon: ""
        property string name: ""
        property bool active: false

        implicitHeight: 36
        radius: 10
        color: active ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.12)
                      : (hover.hovered ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.05) : "transparent")
        border.color: active ? Qt.rgba(global.fgColor.r, global.fgColor.g, global.fgColor.b, 0.25) : "transparent"
        border.width: 1
        
        Behavior on color { ColorAnimation { duration: 150 } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            anchors.rightMargin: 10
            spacing: 12

            Text {
                text: icon
                font.family: global.shellFont.family
                font.pixelSize: 15
                color: global.fgColor
            }

            Text {
                text: name
                font.family: global.shellFont.family
                font.pixelSize: 13
                color: global.fgColor
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }

        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: parent.clicked() }
    }
}
