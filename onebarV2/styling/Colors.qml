pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    property alias primary: jsonAdapter.primary

    FileView {
        path: Quickshell.env("HOME") + "/.cache/quickshell/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonAdapter
            property string primary: "#FFFFFF"
        }
    }
}
