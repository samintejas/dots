import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../theme"

// Dots WorkspaceDots: every dot owns a fixed 20px slot (8px apart), so the
// active one never shifts the others. One 18x6 pill slides between slots.
Item {
    id: root

    required property var screen
    readonly property string screenName: screen ? screen.name : ""
    // 1-5 on the laptop panel, 6-10 on the external (see hyprland.lua)
    readonly property bool isFirstScreen: screenName === "eDP-1"
    readonly property var wsIds: isFirstScreen ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10]
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    readonly property int activeWsId: hyprMonitor && hyprMonitor.activeWorkspace ? hyprMonitor.activeWorkspace.id : -1
    readonly property int activeIndex: wsIds.indexOf(activeWsId)

    readonly property int slot: 20
    readonly property int gap: 8

    // Hyprland's Lua config evaluates the dispatch string as Lua
    function go(wsId) {
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })");
    }

    function workspace(wsId) {
        const vs = Hyprland.workspaces.values;
        for (let i = 0; i < vs.length; i++) {
            if (vs[i].id === wsId)
                return vs[i];
        }
        return null;
    }

    implicitWidth: row.implicitWidth + 16
    implicitHeight: parent.height

    // Scroll over the dots to step through this screen's workspaces.
    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            if (root.activeIndex < 0)
                return;

            const next = Math.max(0, Math.min(root.wsIds.length - 1, root.activeIndex + (event.angleDelta.y < 0 ? 1 : -1)));
            if (next !== root.activeIndex)
                root.go(root.wsIds[next]);
        }
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: root.gap

        Repeater {
            model: root.wsIds

            delegate: Item {
                id: dot

                required property int modelData
                readonly property var ws: root.workspace(modelData)
                readonly property bool isActive: modelData === root.activeWsId
                readonly property bool isUrgent: ws !== null && ws.urgent
                readonly property bool isEmpty: ws === null || ws.toplevels.values.length === 0

                width: root.slot
                height: root.implicitHeight

                // state shape: circle occupied, small square empty, diamond urgent
                Rectangle {
                    anchors.centerIn: parent
                    visible: !dot.isActive
                    width: dot.isUrgent ? 7 : (dot.isEmpty ? 6 : 8)
                    height: width
                    radius: dot.isUrgent ? 0 : (dot.isEmpty ? 1.5 : 4)
                    rotation: dot.isUrgent ? 45 : 0
                    color: dot.isUrgent ? Theme.red : (area.containsMouse ? Theme.dim : (dot.isEmpty ? Theme.empty : Theme.occupied))

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.dur
                        }
                    }
                }

                MouseArea {
                    id: area

                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.go(dot.modelData)
                }
            }
        }
    }

    // the one highlight
    Rectangle {
        visible: root.activeIndex >= 0
        z: 1
        width: 18
        height: 6
        radius: 3
        color: Theme.pink
        y: (root.height - height) / 2
        x: row.x + root.activeIndex * (root.slot + root.gap) + (root.slot - width) / 2

        Behavior on x {
            NumberAnimation {
                duration: Theme.durSlow
                easing.type: Easing.OutQuint
            }
        }
    }
}
