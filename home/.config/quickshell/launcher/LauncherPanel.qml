import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"

// App launcher. Command-palette style: type to filter, up/down to move,
// enter launches, esc closes. Same shell as the clipboard panel.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // only the focused monitor shows it
    readonly property bool active: LauncherState.visible && Hyprland.focusedMonitor === Hyprland.monitorFor(modelData)

    property string query: ""

    // 3 = prefix, 2 = word start / substring, 1 = fuzzy subsequence, 0 = no match
    function score(entry, q) {
        const name = entry.name.toLowerCase();
        if (name.indexOf(q) === 0) return 4;
        if (name.indexOf(" " + q) >= 0) return 3;
        if (name.indexOf(q) >= 0) return 2;
        const extra = ((entry.genericName || "") + " " + (entry.keywords || []).join(" ")).toLowerCase();
        if (extra.indexOf(q) >= 0) return 1.5;
        let i = 0;
        for (let c = 0; c < name.length && i < q.length; c++) {
            if (name[c] === q[i]) i++;
        }
        return i === q.length ? 1 : 0;
    }

    readonly property var shown: {
        const apps = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        const q = query.trim().toLowerCase();
        if (q === "")
            return apps.slice().sort((a, b) => a.name.localeCompare(b.name));
        const scored = [];
        for (let i = 0; i < apps.length; i++) {
            const s = score(apps[i], q);
            if (s > 0) scored.push({ e: apps[i], s: s });
        }
        scored.sort((a, b) => (b.s - a.s) || a.e.name.localeCompare(b.e.name));
        return scored.map(x => x.e);
    }

    function launch() {
        const e = shown[listView.currentIndex];
        if (!e) return;
        LauncherState.visible = false;
        e.execute();
    }

    onActiveChanged: {
        if (active) {
            query = "";
            input.text = "";
            listView.currentIndex = 0;
            input.forceActiveFocus();
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "launcher"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: active

    // scrim: click outside to close
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim

        MouseArea {
            anchors.fill: parent
            onClicked: LauncherState.visible = false
        }
    }

    // palette: overlay layer (as deep as the ground), 520px, solid. Centred on the screen as if the
    // list were full, so the field stays put while results come and go.
    Rectangle {
        id: palette

        width: 520
        height: inputWell.height + listView.height + footer.height + 1 + 24
        anchors.horizontalCenter: parent.horizontalCenter
        readonly property int fullHeight: 8 + 36 + 8 + 8 * 36 + 8 + 28 + 1
        y: Math.round((parent.height - fullHeight) / 2)
        radius: Theme.radiusLg
        color: Theme.overlay
        border.width: 1
        border.color: Theme.borderOverlay

        MouseArea { anchors.fill: parent }   // absorb

        // composite field: the focus mark moves to the container
        Rectangle {
            id: inputWell
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
            height: 36
            radius: Theme.radiusSm
            color: "#000000"
            border.width: input.activeFocus ? 2 : 1
            border.color: input.activeFocus ? Qt.rgba(239 / 255, 156 / 255, 216 / 255, 0.55) : Theme.borderRaised

            TextInput {
                id: input
                anchors { left: parent.left; right: count.left; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 8 }
                font.family: Theme.font
                font.pixelSize: 13
                color: Theme.textHi
                selectionColor: Theme.pink
                selectedTextColor: Theme.base
                clip: true
                focus: true
                onTextChanged: {
                    root.query = text;
                    listView.currentIndex = 0;
                }

                Keys.onEscapePressed: LauncherState.visible = false
                Keys.onReturnPressed: root.launch()
                Keys.onEnterPressed: root.launch()
                Keys.onDownPressed: listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1)
                Keys.onUpPressed: listView.currentIndex = Math.max(0, listView.currentIndex - 1)
                Keys.onPressed: event => {
                    if (event.modifiers & Qt.ControlModifier) {
                        if (event.key === Qt.Key_J || event.key === Qt.Key_N) {
                            listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_K || event.key === Qt.Key_P) {
                            listView.currentIndex = Math.max(0, listView.currentIndex - 1);
                            event.accepted = true;
                        }
                    }
                }

                Text {
                    visible: input.text === "" && !input.preeditText
                    anchors.verticalCenter: parent.verticalCenter
                    text: "search apps"
                    font: input.font
                    color: Theme.subtle
                }
            }

            Text {
                id: count
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
                text: root.shown.length
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.subtle
            }
        }

        ListView {
            id: listView
            anchors { top: inputWell.bottom; left: parent.left; right: parent.right; topMargin: 8; leftMargin: 4; rightMargin: 4 }
            height: root.shown.length === 0 ? 40 : Math.min(root.shown.length, 8) * 36
            clip: true
            model: root.shown
            currentIndex: 0
            highlightMoveDuration: 0
            boundsBehavior: Flickable.StopAtBounds

            delegate: Item {
                id: row
                required property var modelData
                required property int index
                width: listView.width
                height: 36

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: (ListView.isCurrentItem || rowArea.containsMouse) ? Theme.hover : "transparent"
                }

                // current row: short pink bar, as in Sidebar / Menu
                Rectangle {
                    visible: row.ListView.isCurrentItem
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 2 }
                    width: 2
                    height: 16
                    radius: 1
                    color: Theme.pink
                }

                Item {
                    id: icon
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    width: 20
                    height: 20

                    Image {
                        id: img
                        anchors.fill: parent
                        sourceSize: Qt.size(40, 40)
                        asynchronous: true
                        source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, true) : ""
                    }

                    // no icon in the theme: neutral tile with the initial
                    Rectangle {
                        visible: img.status !== Image.Ready
                        anchors.fill: parent
                        radius: Theme.radiusSm
                        color: Theme.empty

                        Text {
                            anchors.centerIn: parent
                            text: row.modelData.name.charAt(0).toLowerCase()
                            font.family: Theme.font
                            font.pixelSize: 11
                            color: Theme.subtle
                        }
                    }
                }

                Text {
                    anchors { left: icon.right; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 8 }
                    text: row.modelData.name
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: row.ListView.isCurrentItem ? Theme.textMax : Theme.textHi
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        listView.currentIndex = row.index;
                        root.launch();
                    }
                }
            }

            Text {
                visible: root.shown.length === 0
                anchors.centerIn: parent
                text: "no matches"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }
        }

        // status line: key hints
        Item {
            id: footer
            anchors { top: listView.bottom; left: parent.left; right: parent.right; topMargin: 8 }
            height: 28

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                text: "↵ launch   ↑↓ move   esc close"
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.subtle
            }
        }
    }
}
