import QtQuick
import Quickshell
import Quickshell.Bluetooth
import "../theme"

// Bluetooth via BlueZ over D-Bus — event-driven. Replaces a 15s timer that
// spawned two bash subshells plus two bluetoothctl processes per tick.
Item {
    id: root

    readonly property bool powered: Bluetooth.defaultAdapter !== null && Bluetooth.defaultAdapter.enabled

    readonly property bool connected: {
        if (!Bluetooth.devices)
            return false;

        const ds = Bluetooth.devices.values;
        for (let i = 0; i < ds.length; i++) {
            if (ds[i].connected)
                return true;

        }
        return false;
    }

    readonly property string icon: connected ? "󰪥" : "○"
    readonly property color textColor: connected ? Theme.blue : Theme.dim

    implicitWidth: 24
    implicitHeight: Theme.barHeight

    readonly property string names: {
        if (!Bluetooth.devices)
            return "";

        const out = [];
        const ds = Bluetooth.devices.values;
        for (let i = 0; i < ds.length; i++) {
            if (ds[i].connected)
                out.push(ds[i].name.toLowerCase());
        }
        return out.join(", ");
    }

    Hint {
        target: root
        text: !powered ? "bluetooth off" : names !== "" ? names : "no device"
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
        color: root.textColor
    }

    MouseArea {
        anchors.fill: parent
        onClicked: PanelState.toggle("bluetooth", root.QsWindow.window ? root.QsWindow.window.screen : null)
    }

    BluetoothPanel {
        target: root
    }
}
