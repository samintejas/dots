import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"

// Clipboard history (cliphist). Command-palette style: type to filter,
// up/down to move, enter copies, delete removes, esc closes.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // only the focused monitor shows it
    readonly property bool active: ClipboardState.visible && Hyprland.focusedMonitor === Hyprland.monitorFor(modelData)

    property var entries: []   // [{ raw, id, text, image }]
    property string query: ""
    readonly property var shown: {
        const q = query.toLowerCase();
        return q === "" ? entries : entries.filter(e => e.text.toLowerCase().indexOf(q) >= 0);
    }

    function parse(out) {
        const list = [];
        const lines = out.split("\n");
        for (let i = 0; i < lines.length; i++) {
            const raw = lines[i];
            const tab = raw.indexOf("\t");
            if (tab < 0) continue;
            let text = raw.substring(tab + 1).trim();
            const m = text.match(/^\[\[ binary data (.*) \]\]$/);
            const image = m !== null;
            if (image) text = "image  " + m[1];
            list.push({ raw: raw, id: raw.substring(0, tab), text: text, image: image });
        }
        entries = list;
        if (list.length > 0) listView.currentIndex = 0;
    }

    function reload() {
        loader.running = true;
    }

    function copyCurrent() {
        const e = shown[listView.currentIndex];
        if (!e) return;
        Quickshell.execDetached(["sh", "-c", "cliphist decode \"$1\" | wl-copy", "_", e.id]);
        ClipboardState.visible = false;
    }

    function removeCurrent() {
        const e = shown[listView.currentIndex];
        if (!e) return;
        const keep = listView.currentIndex;
        remover.command = ["sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "_", e.raw];
        remover.running = true;
        pendingIndex = keep;
    }
    property int pendingIndex: 0

    function wipe() {
        wiper.running = true;
    }

    Process {
        id: loader
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Process {
        id: remover
        onExited: {
            root.reload();
        }
    }

    Process {
        id: wiper
        command: ["cliphist", "wipe"]
        onExited: root.reload()
    }

    onActiveChanged: {
        if (active) {
            query = "";
            input.text = "";
            reload();
            input.forceActiveFocus();
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "clipboard"
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
            onClicked: ClipboardState.visible = false
        }
    }

    // palette: elevation 3, 480px, solid
    Rectangle {
        id: palette

        width: 480
        height: inputWell.height + listView.height + footer.height + 1 + 24
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.16
        radius: Theme.radiusLg
        color: Theme.overlay
        border.width: 1
        border.color: Theme.borderOverlay

        MouseArea { anchors.fill: parent }   // absorb

        // composite field: the focus mark moves to the container
        Rectangle {
            id: inputWell
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
            height: 32
            radius: Theme.radiusSm
            color: Theme.well
            border.width: input.activeFocus ? 2 : 1
            border.color: input.activeFocus ? Theme.focusRing : Theme.borderRaised

            TextInput {
                id: input
                anchors { left: parent.left; right: count.left; verticalCenter: parent.verticalCenter; leftMargin: 10; rightMargin: 8 }
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

                Keys.onEscapePressed: ClipboardState.visible = false
                Keys.onReturnPressed: root.copyCurrent()
                Keys.onEnterPressed: root.copyCurrent()
                Keys.onDownPressed: listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1)
                Keys.onUpPressed: listView.currentIndex = Math.max(0, listView.currentIndex - 1)
                Keys.onDeletePressed: root.removeCurrent()
                Keys.onPressed: event => {
                    if (event.modifiers & Qt.ControlModifier) {
                        if (event.key === Qt.Key_J || event.key === Qt.Key_N) {
                            listView.currentIndex = Math.min(listView.count - 1, listView.currentIndex + 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_K || event.key === Qt.Key_P) {
                            listView.currentIndex = Math.max(0, listView.currentIndex - 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_D) {
                            root.removeCurrent();
                            event.accepted = true;
                        }
                    }
                }

                Text {
                    visible: input.text === "" && !input.preeditText
                    anchors.verticalCenter: parent.verticalCenter
                    text: "search clipboard"
                    font: input.font
                    color: Theme.subtle
                }
            }

            Text {
                id: count
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 10 }
                text: root.shown.length + (root.query !== "" ? "/" + root.entries.length : "")
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.subtle
            }
        }

        ListView {
            id: listView
            anchors { top: inputWell.bottom; left: parent.left; right: parent.right; topMargin: 8; leftMargin: 4; rightMargin: 4 }
            height: root.shown.length === 0 ? 40 : Math.min(root.shown.length, 10) * 28
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
                height: 28

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
                    height: 14
                    radius: 1
                    color: Theme.pink
                }

                Text {
                    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 12; rightMargin: 8 }
                    text: row.modelData.text
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: row.modelData.image ? Theme.textDim : (row.ListView.isCurrentItem ? Theme.textMax : Theme.textHi)
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                MouseArea {
                    id: rowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        listView.currentIndex = row.index;
                        root.copyCurrent();
                    }
                }
            }

            Text {
                visible: root.shown.length === 0
                anchors.centerIn: parent
                text: root.query !== "" ? "no matches" : "clipboard is empty"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }
        }

        // status line: key hints + clear all
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
                text: "↵ copy   del remove   esc close"
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.subtle
            }

            Rectangle {
                visible: root.entries.length > 0
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 6 }
                height: 22
                width: wipeLabel.implicitWidth + 16
                radius: Theme.radiusSm
                color: wipeArea.containsMouse ? Theme.hover : "transparent"

                Text {
                    id: wipeLabel
                    anchors.centerIn: parent
                    text: "clear all"
                    font.family: Theme.font
                    font.pixelSize: 11
                    color: wipeArea.containsMouse ? Theme.red : Theme.textDim
                }

                MouseArea {
                    id: wipeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.wipe()
                }
            }
        }
    }
}
