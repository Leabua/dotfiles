import QtQuick

Item {
    id: icon

    property string name: "clipboard"
    property color color: "white"

    implicitWidth: 18
    implicitHeight: 18
    width: implicitWidth
    height: implicitHeight

    readonly property var paths: ({
        clipboard: '<rect x="5" y="5" width="14" height="16" rx="2"/><rect x="9" y="3" width="6" height="4" rx="1"/><path d="M9 12h6M9 16h4"/>',
        search: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 4.5 4.5"/>',
        image: '<rect x="3" y="3" width="18" height="18" rx="3"/><circle cx="8.5" cy="8.5" r="1.5"/><path d="m21 15-5-5L5 21"/>',
        text: '<path d="M14 3H6a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9Z"/><path d="M14 3v6h6M8 13h8M8 17h5"/>',
        link: '<path d="m10 13 4-4m-6 7-1 1a4 4 0 0 1-6-6l4-4a4 4 0 0 1 6 0m2 10a4 4 0 0 0 6 0l4-4a4 4 0 0 0-6-6l-1 1" transform="translate(1 0) scale(.9)"/>',
        copy: '<rect x="8" y="8" width="13" height="13" rx="2"/><path d="M16 8V5a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h3"/>',
        trash: '<path d="M3 6h18M9 6V3h6v3M5 6l1 15h12l1-15M10 10v7M14 10v7"/>',
        close: '<path d="m6 6 12 12M18 6 6 18"/>',
        activity: '<path d="M3 12h4l3-8 4 16 3-8h4"/>',
        cpu: '<rect x="6" y="6" width="12" height="12" rx="2"/><rect x="9" y="9" width="6" height="6" rx="1"/><path d="M9 2v4m6-4v4M9 18v4m6-4v4M2 9h4m-4 6h4m12-6h4m-4 6h4"/>',
        gpu: '<rect x="3" y="5" width="18" height="13" rx="2"/><circle cx="13" cy="11.5" r="3.5"/><path d="M6 9v5M7 18v3m4-3v3m4-3v3M21 8h1m-1 5h1"/>',
        memory: '<rect x="3" y="6" width="18" height="12" rx="2"/><path d="M7 10v4m5-4v4m5-4v4M7 18v3m5-3v3m5-3v3"/>',
        battery: '<rect x="2" y="6" width="18" height="12" rx="2"/><path d="M22 10v4M6 10v4m4-4v4m4-4v4"/>',
        check: '<path d="m5 12 4 4L19 6"/>',
        chevronDown: '<path d="m6 9 6 6 6-6"/>',
        chevronUp: '<path d="m6 15 6-6 6 6"/>',
        power: '<path d="M12 2v10M5.6 5.6a9 9 0 1 0 12.8 0"/>',
        suspend: '<path d="M20.8 13A8.8 8.8 0 0 1 11 3.2 9 9 0 1 0 20.8 13Z"/>',
        logout: '<path d="M9 5H5a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h4m5-12 5 5-5 5M8 12h13"/>',
        restart: '<path d="M3 10a9 9 0 1 1 1 7M3 4v6h6"/>',
        leaf: '<path d="M20 3c-3 2-7 0-12 3-4 3-4 8-1 11s8 2 10-1c3-4 1-8 3-13Z"/><path d="M4 21 15 10"/>',
        balanced: '<path d="M12 3v18M7 21h10M4 7h16M6 7l-4 8h8L6 7Zm12 0-4 8h8l-4-8Z"/>',
        bolt: '<path d="m13 2-9 12h7l-1 8 10-13h-7l1-7Z"/>',
        speaker: '<path d="m11 5-6 4H2v6h3l6 4V5Zm4 3a5 5 0 0 1 0 8m3-11a9 9 0 0 1 0 14"/>',
        speakerLow: '<path d="m11 5-6 4H2v6h3l6 4V5Zm4 5a3 3 0 0 1 0 4"/>',
        speakerMedium: '<path d="m11 5-6 4H2v6h3l6 4V5Zm4 3a5 5 0 0 1 0 8"/>',
        speakerMuted: '<path d="m11 5-6 4H2v6h3l6 4V5Zm5 4 6 6m0-6-6 6"/>',
        microphone: '<rect x="8" y="2" width="8" height="13" rx="4"/><path d="M5 10v1a7 7 0 0 0 14 0v-1M12 18v4m-4 0h8"/>',
        microphoneMuted: '<path d="M8 6V5a4 4 0 0 1 8 0v6M8 10v1a4 4 0 0 0 6 3M5 10v1a7 7 0 0 0 12 5m2-6v1a7 7 0 0 1-.5 2.5M12 18v4m-4 0h8M2 2l20 20"/>',
        bluetooth: '<path d="m7 7 10 10-5 4V3l5 4L7 17"/>',
        wifi: '<path d="M12 20h.01M8.5 16.4a5 5 0 0 1 7 0M5 12.9a10 10 0 0 1 14 0M2 8.8a15 15 0 0 1 20 0"/>',
        wifiOff: '<path d="M12 20h.01M8.5 16.4a5 5 0 0 1 7 0M5 12.9a10 10 0 0 1 5.2-2.7M19 12.9a10 10 0 0 0-2-1.5M2 8.8a15 15 0 0 1 4.2-2.6M22 8.8a15 15 0 0 0-11.3-3.8M2 2l20 20"/>',
        plus: '<path d="M12 5v14M5 12h14"/>',
        bell: '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.9 1.9 0 0 0 3.4 0"/>',
        calendar: '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/>',
        circle: '<circle cx="12" cy="12" r="9"/>',
        checkCircle: '<circle cx="12" cy="12" r="9"/><path d="m8 12 3 3 5-6"/>',
        grid: '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
        lock: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V7a4 4 0 0 1 8 0v4"/>',
        eye: '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
        eyeOff: '<path d="M9.9 4.2A9 9 0 0 1 12 4c7 0 10 8 10 8a13 13 0 0 1-1.7 2.7M6.6 6.6A13.5 13.5 0 0 0 2 12s3 7 10 7a9.7 9.7 0 0 0 5.4-1.6M14.1 14.1a3 3 0 1 1-4.2-4.2M2 2l20 20"/>',
        headphones: '<path d="M3 14v-3a9 9 0 0 1 18 0v3"/><rect x="3" y="12" width="4" height="9" rx="2"/><rect x="17" y="12" width="4" height="9" rx="2"/>',
        mouse: '<rect x="6" y="2" width="12" height="20" rx="6"/><path d="M12 2v7"/>',
        keyboard: '<rect x="2" y="5" width="20" height="14" rx="2"/><path d="M6 9h.1M10 9h.1M14 9h.1M18 9h.1M6 12h.1M10 12h.1M14 12h.1M18 12h.1M7 16h10"/>',
        phone: '<rect x="6" y="2" width="12" height="20" rx="2"/><path d="M10 18h4"/>',
        computer: '<rect x="3" y="3" width="18" height="13" rx="2"/><path d="M12 16v5m-5 0h10"/>',
        watch: '<rect x="6" y="6" width="12" height="12" rx="4"/><path d="M9 6V2h6v4m-6 12v4h6v-4m-3-9v3l2 1"/>',
        controller: '<path d="M7 7h10c3 0 5 10 3 12-2 1-4-3-5-3H9c-1 0-3 4-5 3C2 17 4 7 7 7Z"/><path d="M7 10v4m-2-2h4m6-1h.1m3 2h.1"/>'
    })

    Image {
        anchors.fill: parent
        sourceSize.width: Math.ceil(width)
        sourceSize.height: Math.ceil(height)
        source: "data:image/svg+xml," + encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="' + Qt.rgba(icon.color.r, icon.color.g, icon.color.b, 1) + '" stroke-opacity="' + icon.color.a + '" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">' + (icon.paths[icon.name] || icon.paths.clipboard) + '</svg>')
    }
}
