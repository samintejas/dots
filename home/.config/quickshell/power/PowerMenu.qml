import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import "../theme"

// Power menu: lock, sleep, log out, restart, shut down. Same shell as the
// launcher: up/down (or the row's letter) to pick, enter to run, esc to close.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // only the focused monitor shows it
    readonly property bool active: PowerState.visible && Hyprland.focusedMonitor === Hyprland.monitorFor(modelData)

    readonly property var actions: [
        { label: "lock",      key: "l", cmd: ["hyprlock"], danger: false },
        { label: "sleep",     key: "s", cmd: ["systemctl", "suspend"], danger: false },
        { label: "log out",   key: "o", cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"], danger: true },
        { label: "restart",   key: "r", cmd: ["systemctl", "reboot"], danger: true },
        { label: "shut down", key: "p", cmd: ["systemctl", "poweroff"], danger: true }
    ]

    function run(i) {
        const a = actions[i];
        if (!a) return;
        PowerState.visible = false;
        Quickshell.execDetached(a.cmd);
    }

    onActiveChanged: {
        if (active) {
            list.currentIndex = 0;
            keys.forceActiveFocus();
        }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "power-menu"
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
            onClicked: PowerState.visible = false
        }
    }

    Rectangle {
        id: menu

        width: 280
        height: list.height + footer.height + 8 + 8
        anchors.centerIn: parent
        radius: Theme.radiusLg
        color: Theme.overlay
        border.width: 1
        border.color: Theme.borderOverlay

        MouseArea { anchors.fill: parent }   // absorb

        FocusScope {
            id: keys
            anchors.fill: parent
            focus: true

            Keys.onEscapePressed: PowerState.visible = false
            Keys.onReturnPressed: root.run(list.currentIndex)
            Keys.onEnterPressed: root.run(list.currentIndex)
            Keys.onDownPressed: list.currentIndex = Math.min(root.actions.length - 1, list.currentIndex + 1)
            Keys.onUpPressed: list.currentIndex = Math.max(0, list.currentIndex - 1)
            Keys.onPressed: event => {
                if (event.modifiers & Qt.ControlModifier) {
                    if (event.key === Qt.Key_J || event.key === Qt.Key_N) {
                        list.currentIndex = Math.min(root.actions.length - 1, list.currentIndex + 1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_K || event.key === Qt.Key_P) {
                        list.currentIndex = Math.max(0, list.currentIndex - 1);
                        event.accepted = true;
                    }
                    return;
                }
                for (let i = 0; i < root.actions.length; i++) {
                    if (event.text === root.actions[i].key) {
                        list.currentIndex = i;
                        root.run(i);
                        event.accepted = true;
                        return;
                    }
                }
            }
        }

        ListView {
            id: list
            anchors { top: parent.top; left: parent.left; right: parent.right; topMargin: 8; leftMargin: 4; rightMargin: 4 }
            height: root.actions.length * 36
            interactive: false
            model: root.actions
            currentIndex: 0
            highlightMoveDuration: 0

            delegate: Item {
                id: row
                required property var modelData
                required property int index
                width: list.width
                height: 36

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.radiusMd
                    color: (ListView.isCurrentItem || area.containsMouse) ? Theme.hover : "transparent"
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

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    text: row.modelData.label
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: row.ListView.isCurrentItem && row.modelData.danger ? Theme.red
                        : row.ListView.isCurrentItem ? Theme.textMax : Theme.textHi
                }

                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 14 }
                    text: row.modelData.key
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Theme.subtle
                }

                MouseArea {
                    id: area
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: list.currentIndex = row.index
                    onClicked: root.run(row.index)
                }
            }
        }

        Item {
            id: footer
            anchors { top: list.bottom; left: parent.left; right: parent.right; topMargin: 8 }
            height: 28

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                text: "↵ run   ↑↓ move   esc close"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }
        }
    }
}
