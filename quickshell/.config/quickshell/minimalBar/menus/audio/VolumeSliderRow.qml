import QtQuick
import QtQuick.Layouts
import qs.templates

RowLayout {
    id: root

    // glyph shown in the left box (nerd-font codepoint); used as the fallback
    // when no app icon resolves
    property int icon: 0xF057E
    // optional app-icon image URL; when it loads it replaces the glyph so a
    // playback row shows *which* app is making sound (see AudioView.appIcon)
    property string iconSource: ""
    // current level, 0..1 (bind to node.audio.volume)
    property real value: 0
    // dim the row + box when the source is muted
    property bool muted: false

    // fired continuously while dragging / on click with the new 0..1 level
    signal moved(real v)
    // fired when the icon box is clicked (used to toggle mute)
    signal iconClicked

    Layout.fillWidth: true
    spacing: Globals.spacing

    // square icon box on the left (app / device glyph, doubles as a mute button)
    Rectangle {
        id: box
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: glyph.implicitHeight + Globals.spacing * 2
        implicitHeight: glyph.implicitHeight + Globals.spacing * 2
        radius: Globals.radius
        color: boxArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.15) : "transparent"
        border.width: 0
        border.color: Qt.alpha(Globals.fgColor, root.muted ? 0.2 : 0.3)

        // real app icon when one resolves, otherwise fall back to the glyph
        readonly property bool hasImg: root.iconSource !== "" && appIcon.status === Image.Ready

        Behavior on color {
            ColorAnimation {
                duration: Globals.animFast
            }
        }

        Image {
            id: appIcon
            anchors.centerIn: parent
            width: glyph.implicitHeight
            height: glyph.implicitHeight
            source: root.iconSource
            sourceSize.width: 44
            sourceSize.height: 44
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            cache: true
            visible: box.hasImg
            opacity: root.muted ? 0.35 : 1
        }

        Text {
            id: glyph
            anchors.centerIn: parent
            visible: !box.hasImg
            text: String.fromCodePoint(root.icon)
            color: Qt.alpha(Globals.fgColor, root.muted ? 0.35 : 1)
            font.family: Globals.textFont.family
            font.pixelSize: Globals.textFont.pixelSize + 10 // one knob: the box + app-icon images size off this glyph
            font.weight: Globals.textFont.weight
        }

        MouseArea {
            id: boxArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    // the slider track; click or drag anywhere along it to set the level
    Rectangle {
        id: track
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        implicitHeight: glyph.implicitHeight / 4
        radius: height
        color: Qt.alpha(Globals.fgColor, 0.25)

        // filled portion up to the current value
        Rectangle {
            id: fill
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * Math.max(0, Math.min(1, root.value))
            radius: parent.radius
            color: Qt.alpha(Globals.fgColor, root.muted ? 0.4 : 1)

            // animate only when not actively dragging so the handle tracks the cursor 1:1
            Behavior on width {
                enabled: !slider.pressed
                NumberAnimation {
                    duration: Globals.animFast
                }
            }
        }

        // round handle riding the end of the fill
        Rectangle {
            id: handle
            width: track.height * 2.2
            height: width
            radius: width / 2
            color: Globals.fgColor
            anchors.verticalCenter: parent.verticalCenter
            x: Math.max(0, Math.min(track.width - width, fill.width - width / 2))
            scale: slider.pressed ? 1.15 : 1
            Behavior on scale {
                NumberAnimation {
                    duration: Globals.animFast
                }
            }
        }

        MouseArea {
            id: slider
            anchors.fill: parent
            anchors.margins: -Globals.spacing // generous hit area so the thin track is easy to grab
            cursorShape: Qt.PointingHandCursor
            preventStealing: true

            function setFromX(mx: real): void {
                const v = Math.max(0, Math.min(1, mx / track.width));
                root.moved(v);
            }

            onPressed: mouse => setFromX(mouse.x)
            onPositionChanged: mouse => {
                if (pressed)
                    setFromX(mouse.x);
            }
        }
    }
}
