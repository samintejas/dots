import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import "../theme"

// Volume / brightness feedback. A Meter row in a raised layer: label, thin
// bar, number. Volume is observed from PipeWire (any source: keys, bar,
// mixer); brightness is pushed in over IPC after the key binding runs.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property bool active: OsdState.visible && Hyprland.focusedMonitor === Hyprland.monitorFor(modelData)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace: "osd"

    anchors { bottom: true }
    margins.bottom: 48
    color: "transparent"
    visible: active || fade.running || box.opacity > 0
    implicitWidth: box.width
    implicitHeight: box.height

    Rectangle {
        id: box
        width: 260
        height: 36
        radius: Theme.radiusLg
        color: Theme.raised
        border.width: 1
        border.color: Theme.borderRaised
        opacity: root.active ? 1 : 0

        Behavior on opacity {
            NumberAnimation { id: fade; duration: Theme.dur; easing.type: Easing.OutQuint }
        }

        RowLayout {
            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
            spacing: 10

            Text {
                Layout.preferredWidth: 78
                text: OsdState.muted ? "muted" : OsdState.label
                font.family: Theme.font
                font.pixelSize: 12
                color: OsdState.muted ? Theme.subtle : Theme.textHi
            }

            // meter: 4px, square ends, grey fill (structure, not state)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                color: Theme.empty

                Rectangle {
                    width: parent.width * Math.min(1, OsdState.percent / 100)
                    height: parent.height
                    color: OsdState.muted ? Theme.ghost : (OsdState.percent > 100 ? Theme.peach : Theme.textDim)
                    Behavior on width { NumberAnimation { duration: Theme.dur; easing.type: Easing.OutQuint } }
                }
            }

            Text {
                Layout.preferredWidth: 32
                horizontalAlignment: Text.AlignRight
                text: OsdState.percent
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.textHi
            }
        }
    }
}
