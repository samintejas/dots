import QtQuick
import Quickshell
import Quickshell.Networking
import "../theme"

// Connectivity via NetworkManager over D-Bus — event-driven. Replaces a 10s
// timer that spawned a bash subshell plus two nmcli processes per tick.
Item {
    id: root

    readonly property var wifiDevice: {
        const ds = Networking.devices.values;
        for (let i = 0; i < ds.length; i++) {
            if (ds[i].type === DeviceType.Wifi)
                return ds[i];

        }
        return null;
    }

    readonly property var wiredDevice: {
        const ds = Networking.devices.values;
        for (let i = 0; i < ds.length; i++) {
            if (ds[i].type === DeviceType.Wired)
                return ds[i];

        }
        return null;
    }

    readonly property var activeWifi: {
        if (!wifiDevice || !wifiDevice.networks)
            return null;

        const ns = wifiDevice.networks.values;
        for (let i = 0; i < ns.length; i++) {
            if (ns[i].connected)
                return ns[i];

        }
        return null;
    }

    // Wired wins over wireless, matching the previous nmcli ordering.
    readonly property bool wiredUp: wiredDevice !== null && wiredDevice.connected
    readonly property bool wifiUp: activeWifi !== null

    // signalStrength is a 0-1 ratio (verified: 0.61 where nmcli reported 74).
    readonly property int signalStrength: activeWifi ? Math.round(activeWifi.signalStrength * 100) : 0

    readonly property string icon: (wiredUp || wifiUp) ? "󰪥" : "○"

    readonly property color textColor: {
        if (wiredUp)
            return Theme.textHi;

        if (!wifiUp)
            return Theme.dim;

        if (signalStrength >= 70)
            return Theme.textHi;

        if (signalStrength >= 40)
            return Theme.peach;

        return Theme.red;
    }

    implicitWidth: 24
    implicitHeight: Theme.barHeight

    Hint {
        target: root
        text: wiredUp ? "wired" : wifiUp ? activeWifi.name.toLowerCase() + " " + signalStrength + "%" : "offline"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: PanelState.toggle("network", root.QsWindow.window ? root.QsWindow.window.screen : null)
    }

    NetworkPanel {
        target: root
        wifiDevice: root.wifiDevice
        wiredDevice: root.wiredDevice
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
        color: root.textColor
    }
}
