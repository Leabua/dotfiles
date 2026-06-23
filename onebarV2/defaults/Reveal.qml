import QtQuick

Item {
    id: root
    property bool shown: false
    property int growDuration: 250
    property int fadeDuration: 150

    visible: shown
    opacity: shown ? 1 : 0

    implicitWidth: children.length ? children[0].implicitWidth : 0
    implicitHeight: children.length ? children[0].implicitHeight : 0

    Behavior on opacity {
        SequentialAnimation {
            PauseAnimation {
                duration: root.growDuration
            }
            NumberAnimation {
                duration: root.fadeDuration
                easing.type: Easing.OutQuad
            }
        }
    }
}
