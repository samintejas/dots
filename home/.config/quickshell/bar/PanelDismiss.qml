import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

// Click-away layer for a popover opened from the keyboard. A click-opened
// popover dismisses itself through the compositor's focus grab; one opened by
// a keybind has no click to grab with, so this transparent sheet catches the
// click instead. Escape: press the same key again.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    visible: PanelState.current !== "" && !PanelState.grab && PanelState.screenName === modelData.name
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "panel-dismiss"

    anchors { top: true; bottom: true; left: true; right: true }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onPressed: PanelState.close()
    }
}
