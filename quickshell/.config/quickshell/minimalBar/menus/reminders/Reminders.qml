pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import qs.templates
import qs.menus.reminders // resolve the sibling EditField

import QtQuick
import QtQuick.Layouts

// Reminders / kanban panel.
Scope {
    id: root

    // HACK: This is where we want our reminders to be stored and how we get them into Obsidian 
    readonly property string filePath: Quickshell.env("HOME") + "/Documents/Uni Notes/Reminder Logs.md"

    // sizing tokens
    readonly property int panelWidth: Math.min(420, (Globals.focusedScreen ? Globals.focusedScreen.width : 1920) - 48)
    readonly property int cardPadH: 10
    readonly property int cardPadV: 10
    readonly property int cardGap: 7 // breathing room each side of the between-card divider

    // "active" (the two reminder buckets) | "completed"
    property string view: "active"
    property bool loaded: false

    // ----- edit state (only one card edits at a time) -----
    property bool editing: false
    property string editBucket: "priority" // which bucket the edited card lives in
    property int editIndex: -1             // its row in that bucket's model
    property bool editIsNew: false         // a freshly added blank -> discard on cancel
    property string editField: "title"     // "title" | "subject" | "date"
    property string draftTitle: ""
    property string draftSubject: ""
    property string draftDate: ""
    onEditingChanged: {
        if (!editing && Globals.remindersOpen)
            Qt.callLater(popup.focusMenu);
    }

    // ----- models (one row per reminder; roles are flat strings) -----
    ListModel {
        id: priorityModel
    }
    ListModel {
        id: laterModel
    }
    ListModel {
      id: completedModel 
    }

    function modelFor(bucket: string): var {
        return bucket === "priority" ? priorityModel : laterModel;
    }

    function todayStr(): string {
        return Qt.formatDateTime(new Date(), "yyyy-MM-dd");
    }

    // ----- editing -----
    function startAdd(): void {
        if (root.editing)
            return;
        priorityModel.insert(0, {
            title: "",
            subject: "",
            date: ""
        });
        root.editBucket = "priority";
        root.editIndex = 0;
        root.editIsNew = true;
        root.draftTitle = "";
        root.draftSubject = "";
        root.draftDate = "";
        root.editField = "title";
        root.editing = true;
    }

    function startEdit(bucket: string, index: int): void {
        if (root.editing)
            return;
        const m = root.modelFor(bucket);
        if (index < 0 || index >= m.count)
            return;
        const it = m.get(index);
        root.draftTitle = it.title;
        root.draftSubject = it.subject;
        root.draftDate = it.date;
        root.editBucket = bucket;
        root.editIndex = index;
        root.editIsNew = false;
        root.editField = "title";
        root.editing = true;
    }

    function confirmEdit(): void {
        if (!root.editing)
            return;
        if (root.draftTitle.trim() === "") {
            root.cancelEdit(); // a titleless reminder is meaningless -> treat as a cancel
            return;
        }
        const m = root.modelFor(root.editBucket);
        m.setProperty(root.editIndex, "title", root.draftTitle.trim());
        m.setProperty(root.editIndex, "subject", root.draftSubject.trim());
        m.setProperty(root.editIndex, "date", root.draftDate.trim());
        root.editing = false;
        root.editIndex = -1;
        root.editIsNew = false;
        root.scheduleSave();
    }

    function cancelEdit(): void {
        if (!root.editing)
            return;
        if (root.editIsNew) {
            const m = root.modelFor(root.editBucket);
            if (root.editIndex >= 0 && root.editIndex < m.count)
                m.remove(root.editIndex);
        }
        root.editing = false;
        root.editIndex = -1;
        root.editIsNew = false;
    }

    function cycleField(delta: int): void {
        const order = ["title", "subject", "date"];
        const i = order.indexOf(root.editField);
        root.editField = order[(i + delta + order.length) % order.length];
    }

    function handleKey(event): void {
        if (!root.editing)
            return;
        const k = event.key;
        if ((k === Qt.Key_Return || k === Qt.Key_Enter) && (event.modifiers & Qt.ControlModifier)) {
            root.confirmEdit();
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Escape) {
            root.cancelEdit();
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Return || k === Qt.Key_Enter) {
            if (root.editField === "title")
                root.editField = "subject";
            else if (root.editField === "subject")
                return; // Enter inserts a newline in the details field.
            else
                root.confirmEdit();
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Tab && !(event.modifiers & Qt.ShiftModifier)) {
            root.cycleField(1);
            event.accepted = true;
            return;
        }
        if (k === Qt.Key_Backtab || (k === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier))) {
            root.cycleField(-1);
            event.accepted = true;
            return;
        }
    }

    // ----- completing / restoring -----
    function completeReminder(bucket: string, index: int): void {
        if (root.editing)
            return;
        const m = root.modelFor(bucket);
        if (index < 0 || index >= m.count)
            return;
        const it = m.get(index);
        completedModel.insert(0, {
            title: it.title,
            subject: it.subject,
            date: it.date,
            bucket: bucket,
            completedAt: root.todayStr()
        });
        m.remove(index);
        root.scheduleSave();
    }

    function uncompleteReminder(index: int): void {
        if (index < 0 || index >= completedModel.count)
            return;
        const it = completedModel.get(index);
        root.modelFor(it.bucket).append({
            title: it.title,
            subject: it.subject,
            date: it.date
        });
        completedModel.remove(index);
        root.scheduleSave();
    }

    function clearCompleted(): void {
        completedModel.clear();
        root.scheduleSave();
    }

    /*drag/drop reorder (resolved next tick so we never mutate a model from
     inside the delegate's own released handler) */
    function applyDrop(srcBucket: string, srcIndex: int, tgtBucket: string, tgtIndex: int): void {
        const sm = root.modelFor(srcBucket);
        if (srcIndex < 0 || srcIndex >= sm.count)
            return;
        if (srcBucket === tgtBucket) {
            let to = tgtIndex;
            if (to < 0 || to >= sm.count)
                to = sm.count - 1;
            if (to !== srcIndex)
                sm.move(srcIndex, to, 1);
        } else {
            const tm = root.modelFor(tgtBucket);
            const it = sm.get(srcIndex);
            const data = {
                title: it.title,
                subject: it.subject,
                date: it.date
            };
            sm.remove(srcIndex);
            let to = tgtIndex;
            if (to < 0 || to > tm.count)
                to = tm.count;
            tm.insert(to, data);
        }
        root.scheduleSave();
    }

    // ----- 2-week auto prune of completed items -----
    function pruneCompleted(): void {
        const cutoff = new Date();
        cutoff.setDate(cutoff.getDate() - 14);
        const cut = Qt.formatDateTime(cutoff, "yyyy-MM-dd");
        for (let i = completedModel.count - 1; i >= 0; i--) {
            const d = completedModel.get(i).completedAt;
            if (!d || d < cut) 
                completedModel.remove(i);
        }
    }

    // ----- persistence: Obsidian-flavoured markdown -----
    function activeLine(it): string {
        let s = "- [ ] **" + it.title + "**";
        if (it.date && it.date.length)
            s += " 📅 " + it.date; // Obsidian Tasks due-date glyph
        if (it.subject && it.subject.length)
            s += "\n" + it.subject.split("\n").map(line => "    " + line).join("\n");
        return s;
    }

    function serialize(): string {
        let out = "# Reminder Logs\n\n";
        out += "## Priority\n";
        for (let i = 0; i < priorityModel.count; i++) {
            const it = priorityModel.get(i);
            if (it.title && it.title.trim().length)
                out += root.activeLine(it) + "\n";
        }
        out += "\n## When you have the time\n";
        for (let j = 0; j < laterModel.count; j++) {
            const it2 = laterModel.get(j);
            if (it2.title && it2.title.trim().length)
                out += root.activeLine(it2) + "\n";
        }
        out += "\n## Completed\n";
        for (let k = 0; k < completedModel.count; k++) {
            const it3 = completedModel.get(k);
            if (!it3.title || !it3.title.trim().length)
                continue;
            let s = "- [x] **" + it3.title + "**";
            if (it3.date)
                s += " 📅 " + it3.date;
            if (it3.completedAt && it3.completedAt.length)
                s += " ✅ " + it3.completedAt; 
            s += " <!-- bucket:" + (it3.bucket || "priority") + " -->";
            if (it3.subject)
                s += "\n" + it3.subject.split("\n").map(line => "    " + line).join("\n");
            out += s + "\n";
        }
        return out;
    }

    // Claude goated for this one
    function loadFromText(text: string): void {
        priorityModel.clear();
        laterModel.clear();
        completedModel.clear();
        if (text && text.length) {
            const lines = text.split("\n");
            let section = "";
            let lastModel = null;
            let lastIndex = -1;
            for (const raw of lines) {
                if (lastModel && /^ {4}/.test(raw)) {
                    const previous = lastModel.get(lastIndex).subject;
                    lastModel.setProperty(lastIndex, "subject", previous ? previous + "\n" + raw.substring(4) : raw.substring(4));
                    continue;
                }
                const t = raw.trim();
                if (t.startsWith("## ")) {
                    lastModel = null;
                    const h = t.substring(3).trim().toLowerCase();
                    if (h.indexOf("complete") >= 0)
                        section = "completed";
                    else if (h.indexOf("priority") >= 0)
                        section = "priority";
                    else if (h.indexOf("time") >= 0 || h.indexOf("later") >= 0)
                        section = "later";
                    else
                        section = "";
                    continue;
                }
                const m = t.match(/^- \[( |x|X)\]\s*(.*)$/);
                if (!m)
                    continue;
                const checked = m[1].toLowerCase() === "x";
                let rest = m[2];
                const bucketMatch = rest.match(/<!-- bucket:(priority|later) -->/);
                const bucket = bucketMatch ? bucketMatch[1] : "priority";
                rest = rest.replace(/<!-- bucket:(priority|later) -->/, "").trim();

                let completedAt = "";
                const cm = rest.match(/✅\s*(\d{4}-\d{2}-\d{2})/);
                if (cm) {
                    completedAt = cm[1];
                    rest = rest.replace(cm[0], "").trim();
                }
                let date = "";
                const dm = rest.match(/📅\s*(.+?)\s*$/);
                if (dm) {
                    date = dm[1].trim();
                    rest = rest.replace(/📅\s*.+?\s*$/, "").trim();
                }
                rest = rest.replace(/~~/g, "").trim();

                let title = rest;
                let subject = "";
                const tm = rest.match(/\*\*([\s\S]*?)\*\*/);
                if (tm) {
                    title = tm[1].trim();
                    let after = rest.substring(rest.indexOf(tm[0]) + tm[0].length).trim();
                    after = after.replace(/^[—–-]\s*/, "").trim();
                    subject = after;
                }
                if (!title.length)
                    continue;

                if (section === "completed" || checked) {
                    completedModel.append({
                        title: title,
                        subject: subject,
                        date: date,
                        bucket: bucket,
                        completedAt: completedAt
                    });
                    lastModel = completedModel;
                } else if (section === "later") {
                    laterModel.append({
                        title: title,
                        subject: subject,
                        date: date
                    });
                    lastModel = laterModel;
                } else {
                    priorityModel.append({
                        title: title,
                        subject: subject,
                        date: date
                    });
                    lastModel = priorityModel;
                }
                lastIndex = lastModel.count - 1;
            }
        }
        root.pruneCompleted();
        root.loaded = true;
    }

    function saveNow(): void {
        if (!root.loaded)
            return;
        reminderFile.setText(root.serialize());
    }
    function scheduleSave(): void {
        saveTimer.restart();
    }

    Timer {
        id: saveTimer
        interval: 400
        onTriggered: root.saveNow()
    }

    Process {
        id: loadProc
        command: ["cat", root.filePath]
        stdout: StdioCollector {
            onStreamFinished: root.loadFromText(text)
        }
        onExited: (code, status) => {
            if (code !== 0) // file missing -> drop the scaffold into the vault so it's visibly linked
                root.saveNow();
        }
    }

    FileView {
        id: reminderFile
        path: root.filePath
        atomicWrites: true
        printErrors: false
    }

    Component.onCompleted: loadProc.running = true

    IpcHandler {
        target: "reminders"
        function toggle(): void {
            Globals.remindersOpen = !Globals.remindersOpen;
        }
        function show(): void {
            Globals.remindersOpen = true;
        }
        function hide(): void {
            Globals.remindersOpen = false;
        }
    }

    // always reopen on the active reminders view + freshen the pruning
    Connections {
        target: Globals
        function onRemindersOpenChanged(): void {
            if (Globals.remindersOpen) {
                if (root.editing)
                    root.cancelEdit();
                root.view = "active";
                root.pruneCompleted();
            }
        }
    }
    
    PopupWindow {
        id: popup
        open: Globals.remindersOpen
        onDismissed: {
            if (root.editing)
                root.cancelEdit();
            Globals.remindersOpen = false;
        }
        hAlign: "right"
        screen: Globals.focusedScreen // open on the focused monitor, like the notification center
        padding: 16
        backgroundColor: Globals.bgColor
        onKeyDown: event => root.handleKey(event)

        // ~~~ the right island is the only bar element above a right-aligned card -> ride to the top when it's gone ~~~
        margins {
            top: Globals.marginsTop + (Globals.barShown && Globals.rightIslandShown ? Globals.currentBarHeight + Globals.hyprGaps : 0)
            right: Globals.marginsRight
        }

        Loader {
            width: root.panelWidth
            height: item ? item.implicitHeight : 0 // explicit so the card's childrenRect tracks the content reliably
            sourceComponent: root.view === "completed" ? completedComponent : activeComponent
        }
    }

    //  ACTIVE VIEW 
    Component {
        id: activeComponent

        Item {
            id: activeRoot
            implicitWidth: root.panelWidth
            implicitHeight: col.implicitHeight

            readonly property bool hasAny: priorityModel.count > 0 || laterModel.count > 0 || root.editing


            ColumnLayout {
                id: col
                width: root.panelWidth
                spacing: 6

                MenuHeader {
                    Layout.bottomMargin: 8
                    title: "Reminders"
                    icon: "bell"
                    actionText: "Add"
                    actionIcon: "plus"
                    actionEnabled: !root.editing
                    onActionClicked: root.startAdd()
                    onCloseRequested: Globals.remindersOpen = false
                }

                // empty state: an invitation to act, not a mood
                ColumnLayout {
                    visible: !activeRoot.hasAny
                    Layout.fillWidth: true
                    Layout.topMargin: 16
                    Layout.bottomMargin: 20
                    spacing: 6

                    MenuIcon {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 28
                        Layout.bottomMargin: 4
                        name: "bell"
                        color: Qt.alpha(Globals.fgColor, 0.25)
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "Nothing on the list"
                        color: Qt.alpha(Globals.fgColor, 0.8)
                        font.family: Globals.textFont.family
                        font.pixelSize: 14
                        font.weight: Font.Medium
                    }
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: "Add a reminder to get started"
                        color: Qt.alpha(Globals.fgColor, 0.45)
                        font.family: Globals.textFont.family
                        font.pixelSize: 13
                    }
                }

                // ----- Priority section -----
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: root.cardPadH
                    visible: activeRoot.hasAny
                    spacing: 6

                    // the one red in the panel: it marks what's urgent, nothing else
                    MenuSectionLabel {
                        inset: 0
                        text: "Priority"
                        color: Qt.alpha(Globals.criticalColor, 0.85)
                    }
                    MenuSectionLabel {
                        inset: 0
                        visible: priorityModel.count > 0
                        text: priorityModel.count
                    }
                }

                ListView {
                    id: priorityList
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    interactive: false
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 0
                    model: priorityModel
                    delegate: cardComponent
                }

                // ----- "When you have the time" section -----
                RowLayout {
                    id: laterHeading
                    Layout.fillWidth: true
                    Layout.leftMargin: root.cardPadH
                    Layout.topMargin: 8
                    visible: activeRoot.hasAny
                    spacing: 6

                    MenuSectionLabel {
                        inset: 0
                        text: "When you have the time"
                    }
                    MenuSectionLabel {
                        inset: 0
                        visible: laterModel.count > 0
                        text: laterModel.count
                    }
                }

                ListView {
                    id: laterList
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    visible: activeRoot.hasAny
                    interactive: false
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 0
                    model: laterModel
                    delegate: cardComponent
                }

                //  footer: switch to completed (hugs the right edge)
                RowLayout {
                    id: footerRow
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Item {
                        Layout.fillWidth: true
                    }
                    MenuButton {
                        id: completedBtn
                        icon: "checkCircle"
                        text: completedModel.count > 0 ? completedModel.count + " completed" : "Completed"
                        onClicked: {
                            if (root.editing)
                                root.confirmEdit();
                            root.view = "completed";
                        }
                    }
                }
            }

            Item {
                id: dragLayer
                anchors.fill: col
                z: 999
            }

            Component {
                id: cardComponent

                Item {
                    id: wrapper
                    required property int index
                    required property string title
                    required property string subject
                    required property string date

                    readonly property var ownerList: ListView.view
                    readonly property string bucket: ownerList === priorityList ? "priority" : "later"
                    readonly property bool isEditing: root.editing && root.editBucket === bucket && root.editIndex === wrapper.index

                    width: ownerList ? ownerList.width : root.panelWidth
                    implicitHeight: holder.implicitHeight + root.cardGap * 2 + 1
                    height: implicitHeight
                    z: holderMa.drag.active ? 1000 : 1

                    Item {
                        id: holder
                        anchors.left: wrapper.left
                        anchors.right: wrapper.right
                        anchors.top: wrapper.top
                        implicitHeight: contentRow.implicitHeight + root.cardPadV * 2
                        height: implicitHeight

                        states: State {
                            when: holderMa.drag.active
                            ParentChange {
                                target: holder
                                parent: dragLayer
                            }
                            AnchorChanges {
                                target: holder
                                anchors.left: undefined
                                anchors.right: undefined
                                anchors.top: undefined
                            }
                        }

                        // hover / editing / drag background
                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: {
                                if (holderMa.drag.active)
                                    return Qt.alpha(Globals.fgColor, 0.14);
                                if (wrapper.isEditing)
                                    return Qt.alpha(Globals.fgColor, 0.08);
                                if (cardHover.hovered)
                                    return Qt.alpha(Globals.fgColor, 0.04);
                                return "transparent";
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: Globals.animFast
                                }
                            }
                        }

                        HoverHandler {
                            id: cardHover
                            enabled: !root.editing
                        }

                        RowLayout {
                            id: contentRow
                            anchors.left: holder.left
                            anchors.right: holder.right
                            anchors.top: holder.top
                            anchors.leftMargin: root.cardPadH
                            anchors.rightMargin: root.cardPadH
                            anchors.topMargin: root.cardPadV
                            spacing: 10

                            // ----- text column -----
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 4

                                // title
                                EditField {
                                    Layout.fillWidth: true
                                    visible: wrapper.isEditing
                                    value: root.draftTitle
                                    placeholder: "Title"
                                    pixelSize: 14
                                    weight: Font.Medium
                                    active: wrapper.isEditing && root.editField === "title"
                                    onTapped: root.editField = "title"
                                    onEdited: value => root.draftTitle = value.replace(/\n/g, " ")
                                    onKeyPressed: event => root.handleKey(event)
                                }
                                Text {
                                    Layout.fillWidth: true
                                    visible: !wrapper.isEditing
                                    text: wrapper.title
                                    color: Globals.fgColor
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    textFormat: Text.PlainText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }

                                // subject
                                EditField {
                                    Layout.fillWidth: true
                                    visible: wrapper.isEditing
                                    value: root.draftSubject
                                    placeholder: "Details, notes, links"
                                    multiline: true
                                    pixelSize: 13
                                    weight: Font.Normal
                                    active: wrapper.isEditing && root.editField === "subject"
                                    onTapped: root.editField = "subject"
                                    onEdited: value => root.draftSubject = value
                                    onKeyPressed: event => root.handleKey(event)
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 1
                                    visible: !wrapper.isEditing && wrapper.subject !== ""
                                    text: wrapper.subject
                                    color: Qt.alpha(Globals.fgColor, 0.6)
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 13
                                    lineHeight: 1.15
                                    textFormat: Text.PlainText
                                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                                }

                                // date (edit row)
                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.topMargin: 2
                                    visible: wrapper.isEditing
                                    spacing: Globals.spacing - 2

                                    MenuIcon {
                                        Layout.preferredWidth: 14
                                        Layout.preferredHeight: 14
                                        name: "calendar"
                                        color: Qt.alpha(Globals.fgColor, 0.45)
                                    }
                                    EditField {
                                        Layout.fillWidth: true
                                        value: root.draftDate
                                        placeholder: "Due date (optional)"
                                        pixelSize: 12
                                        weight: Font.Normal
                                        active: root.editField === "date"
                                        onTapped: root.editField = "date"
                                        onEdited: value => root.draftDate = value.replace(/\n/g, " ")
                                        onKeyPressed: event => root.handleKey(event)
                                    }
                                }

                                // date chip (display)
                                Rectangle {
                                    Layout.topMargin: 3
                                    visible: !wrapper.isEditing && wrapper.date !== ""
                                    implicitWidth: chipRow.implicitWidth + 14
                                    implicitHeight: 22
                                    radius: 6
                                    color: Qt.alpha(Globals.fgColor, 0.07)

                                    RowLayout {
                                        id: chipRow
                                        anchors.centerIn: parent
                                        spacing: 5

                                        MenuIcon {
                                            Layout.preferredWidth: 12
                                            Layout.preferredHeight: 12
                                            name: "calendar"
                                            color: Qt.alpha(Globals.fgColor, 0.55)
                                        }
                                        Text {
                                            text: wrapper.date
                                            color: Qt.alpha(Globals.fgColor, 0.7)
                                            font.family: Globals.textFont.family
                                            font.pixelSize: 12
                                        }
                                    }
                                }

                                // edit hint
                                Text {
                                    Layout.topMargin: 3
                                    visible: wrapper.isEditing
                                    text: "Tab to move, Ctrl+Enter to save, Esc to cancel"
                                    color: Qt.alpha(Globals.fgColor, 0.35)
                                    font.family: Globals.textFont.family
                                    font.pixelSize: 12
                                }
                            }

                            // ----- complete circle / confirm check -----
                            // hovering previews the outcome: the empty ring fills with a check
                            Rectangle {
                                Layout.alignment: Qt.AlignTop
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
                                color: circleArea.containsMouse ? Qt.alpha(wrapper.isEditing ? Globals.healthy : Globals.fgColor, 0.1) : "transparent"
                                scale: circleArea.pressed ? 0.92 : 1

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Globals.animPress
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                MenuIcon {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    name: wrapper.isEditing ? "check" : circleArea.containsMouse ? "checkCircle" : "circle"
                                    color: wrapper.isEditing ? Globals.healthy : Qt.alpha(Globals.fgColor, circleArea.containsMouse ? 0.9 : 0.45)
                                }

                                MouseArea {
                                    id: circleArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (wrapper.isEditing)
                                            root.confirmEdit();
                                        else
                                            root.completeReminder(wrapper.bucket, wrapper.index);
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: holderMa
                            anchors.fill: parent
                            z: -1
                            enabled: !root.editing
                            cursorShape: Qt.PointingHandCursor
                            property bool didDrag: false

                            drag.target: holder
                            drag.axis: Drag.YAxis

                            onPressed: didDrag = false
                            onPositionChanged: if (drag.active)
                                didDrag = true
                            onClicked: if (!didDrag)
                                root.startEdit(wrapper.bucket, wrapper.index)
                            onReleased: {
                                if (!didDrag)
                                    return;
                                // above the "later" heading -> priority bucket, else later
                                const gp = holder.mapToItem(null, holder.width / 2, holder.height / 2);
                                const bnd = laterHeading.mapToItem(null, 0, 0).y;
                                const tgtBucket = gp.y >= bnd ? "later" : "priority";
                                const tgtList = tgtBucket === "later" ? laterList : priorityList;
                                const lp = tgtList.mapFromItem(null, gp.x, gp.y);
                                let idx = tgtList.indexAt(Math.max(1, Math.min(tgtList.width - 1, lp.x)), lp.y + tgtList.contentY);
                                Qt.callLater(root.applyDrop, wrapper.bucket, wrapper.index, tgtBucket, idx);
                            }
                        }
                    }

                    // hairline divider, centred in the gap below the card
                    Rectangle {
                        anchors.left: wrapper.left
                        anchors.right: wrapper.right
                        anchors.bottom: wrapper.bottom
                        anchors.bottomMargin: root.cardGap
                        anchors.leftMargin: root.cardPadH
                        anchors.rightMargin: root.cardPadH
                        height: 1
                        color: Qt.alpha(Globals.fgColor, 0.07)
                    }
                }
            }
        }
    }

    // ===================== COMPLETED VIEW 
    Component {
        id: completedComponent

        Item {
            implicitWidth: root.panelWidth
            implicitHeight: ccol.implicitHeight

            ColumnLayout {
                id: ccol
                width: root.panelWidth
                spacing: 6

                MenuHeader {
                    Layout.bottomMargin: 8
                    title: "Completed"
                    icon: "checkCircle"
                    actionText: "Clear all"
                    actionDestructive: true
                    actionEnabled: completedModel.count > 0
                    onActionClicked: root.clearCompleted()
                    onCloseRequested: Globals.remindersOpen = false
                }

                Text {
                    visible: completedModel.count === 0
                    Layout.fillWidth: true
                    Layout.leftMargin: root.cardPadH
                    Layout.bottomMargin: 8
                    text: "Finished reminders stay here for two weeks"
                    color: Qt.alpha(Globals.fgColor, 0.5)
                    font.family: Globals.textFont.family
                    font.pixelSize: 13
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: contentHeight
                    visible: completedModel.count > 0
                    interactive: false
                    boundsBehavior: Flickable.StopAtBounds
                    spacing: 0
                    model: completedModel
                    delegate: Item {
                        id: cwrapper
                        required property int index
                        required property string title

                        width: ListView.view ? ListView.view.width : root.panelWidth
                        implicitHeight: crow.implicitHeight + root.cardPadV * 2 + root.cardGap * 2 + 1
                        height: implicitHeight

                        RowLayout {
                            id: crow
                            anchors.left: cwrapper.left
                            anchors.right: cwrapper.right
                            anchors.top: cwrapper.top
                            anchors.leftMargin: root.cardPadH
                            anchors.rightMargin: root.cardPadH
                            anchors.topMargin: root.cardPadV
                            spacing: 10

                            Text {
                                Layout.fillWidth: true
                                text: cwrapper.title
                                color: Qt.alpha(Globals.fgColor, 0.45)
                                font.family: Globals.textFont.family
                                font.pixelSize: 14
                                font.strikeout: true
                                textFormat: Text.PlainText
                                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            }

                            // check -> send back to the reminders list as incomplete (hover previews the empty ring)
                            Rectangle {
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: 28
                                implicitHeight: 28
                                radius: 14
                                color: cCheckArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.1) : "transparent"
                                scale: cCheckArea.pressed ? 0.92 : 1

                                Behavior on scale {
                                    NumberAnimation {
                                        duration: Globals.animPress
                                        easing.type: Easing.OutCubic
                                    }
                                }

                                MenuIcon {
                                    anchors.centerIn: parent
                                    width: 20
                                    height: 20
                                    name: cCheckArea.containsMouse ? "circle" : "checkCircle"
                                    color: cCheckArea.containsMouse ? Qt.alpha(Globals.fgColor, 0.7) : Globals.healthy
                                }

                                MouseArea {
                                    id: cCheckArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.uncompleteReminder(cwrapper.index)
                                }
                            }
                        }

                        Rectangle {
                            anchors.left: cwrapper.left
                            anchors.right: cwrapper.right
                            anchors.bottom: cwrapper.bottom
                            anchors.bottomMargin: root.cardGap
                            anchors.leftMargin: root.cardPadH
                            anchors.rightMargin: root.cardPadH
                            height: 1
                            color: Qt.alpha(Globals.fgColor, 0.07)
                        }
                    }
                }

                // footer: back to the reminders list (hugs the right edge)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Item {
                        Layout.fillWidth: true
                    }
                    MenuButton {
                        icon: "bell"
                        text: "Back to reminders"
                        onClicked: root.view = "active"
                    }
                }
            }
        }
    }
}
