pragma ComponentBehavior: Bound
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import qs.templates

// the power menu's trigger at the foot of the rail: the distro mark on an M3 Expressive "cookie" (a scalloped
// circle). The cookie turns a little on hover and a little more while its menu is open; the mark stays upright
Item {
    id: root

    property string distroId: ""
    readonly property var glyphs: ({
            "arch": "󰣇",
            "ubuntu": "󰕈",
            "fedora": "󰣛",
            "debian": "󰣚",
            "manjaro": "󱘊",
            "nixos": "󱄅",
            "opensuse-tumbleweed": "󰮤",
            "opensuse-leap": "󰮤",
            "gentoo": "󰣨",
            "endeavouros": "󰣇",
            "pop": "󰣇"
        })

    readonly property bool open: Globals.powerMenuOpen

    implicitWidth: Globals.railItemWidth
    implicitHeight: Globals.railItemWidth
    Layout.alignment: Qt.AlignHCenter

    scale: mouse.pressed ? 0.9 : 1
    Behavior on scale {
        NumberAnimation {
            duration: Globals.animPress
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Globals.easeOut
        }
    }

    Shape {
        id: cookie
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        rotation: root.open ? 40 : mouse.containsMouse ? 20 : 0
        Behavior on rotation {
            NumberAnimation {
                duration: 420 // decorative and rare -> allowed to take its time settling
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Globals.easeSpatial
            }
        }

        ShapePath {
            strokeWidth: 0
            strokeColor: "transparent"
            fillColor: root.open ? Globals.primary : Globals.primaryContainer
            Behavior on fillColor {
                ColorAnimation {
                    duration: Globals.animDuration
                }
            }

            PathPolyline {
                // r(t) = R (1 + a cos(9t)) -> nine soft lobes, the M3 "cookie 9" silhouette
                path: {
                    const pts = [];
                    const c = cookie.width / 2;
                    const R = c / 1.09;
                    for (let i = 0; i <= 180; i++) {
                        const t = i / 180 * Math.PI * 2;
                        const r = R * (1 + 0.09 * Math.cos(9 * t));
                        pts.push(Qt.point(c + r * Math.cos(t), c + r * Math.sin(t)));
                    }
                    return pts;
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.glyphs[root.distroId] ?? "󰻀"
        color: root.open ? Globals.primaryContent : Globals.primaryContainerContent
        font.family: "Maple Mono NF" // nerd glyph -> a non-Mono NF face keeps it full width
        font.pixelSize: 18
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const c = root.mapToItem(null, root.width / 2, root.height / 2);
            Globals.menuAnchorX = c.x;
            Globals.toggleMenu("powerMenu");
        }
    }

    Process {
        command: ["sh", "-c", ". /etc/os-release && echo $ID"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.distroId = text.trim()
        }
    }
}
