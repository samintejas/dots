import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import "../theme"

// Bluetooth popover, macOS style: switch in the header, "my devices" then
// "nearby". Click a device to connect; click a connected one to disconnect.
PopoverPanel {
    id: panel

    readonly property var adapter: Bluetooth.defaultAdapter

    name: "bluetooth"
    title: "bluetooth"
    checked: adapter !== null && adapter.enabled
    onToggled: value => { if (adapter) adapter.enabled = value }

    onVisibleChanged: {
        if (adapter)
            adapter.discovering = visible && adapter.enabled
    }

    function glyph(cp) { return String.fromCodePoint(cp) }

    function deviceIcon(d) {
        const i = d.icon || ""
        if (i.indexOf("headset") >= 0 || i.indexOf("headphone") >= 0) return glyph(0xF02CB)
        if (i.indexOf("mouse") >= 0) return glyph(0xF037D)
        if (i.indexOf("keyboard") >= 0) return glyph(0xF030C)
        if (i.indexOf("phone") >= 0) return glyph(0xF03F2)
        if (i.indexOf("audio") >= 0 || i.indexOf("speaker") >= 0) return glyph(0xF04C3)
        if (i.indexOf("gaming") >= 0 || i.indexOf("joystick") >= 0) return glyph(0xF02B4)
        return glyph(d.connected ? 0xF00B1 : 0xF00AF)
    }

    function label(d) { return d.name || d.deviceName || d.address }

    function sorted(wantPaired) {
        if (!adapter || !adapter.devices) return []
        const out = []
        const ds = adapter.devices.values
        for (let i = 0; i < ds.length; i++) {
            if ((ds[i].paired || ds[i].bonded) === wantPaired)
                out.push(ds[i])
        }
        out.sort((a, b) => (b.connected - a.connected) || label(a).localeCompare(label(b)))
        return out
    }

    readonly property var mine: sorted(true)
    // unnamed advertisers are just a MAC address: noise
    readonly property var nearby: sorted(false).filter(d => !/^([0-9a-f]{2}[-:_]){5}[0-9a-f]{2}$/i.test(label(d).trim()))

    function tap(d) {
        if (d.connected) d.disconnect()
        else if (d.paired || d.bonded) d.connect()
        else d.pair()
    }

    Text {
        visible: !panel.adapter
        Layout.fillWidth: true
        Layout.topMargin: 12
        Layout.bottomMargin: 12
        horizontalAlignment: Text.AlignHCenter
        text: "no bluetooth adapter"
        font.family: Theme.font
        font.pixelSize: 12
        color: Theme.subtle
    }

    Text {
        visible: panel.adapter && !panel.adapter.enabled
        Layout.fillWidth: true
        Layout.topMargin: 12
        Layout.bottomMargin: 12
        horizontalAlignment: Text.AlignHCenter
        text: "bluetooth is off"
        font.family: Theme.font
        font.pixelSize: 12
        color: Theme.subtle
    }

    Flickable {
        id: scroller
        visible: panel.adapter && panel.adapter.enabled
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(list.implicitHeight, 360)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list
            width: scroller.width
            spacing: 2

            Text {
                visible: panel.mine.length > 0
                Layout.leftMargin: 8
                Layout.topMargin: 2
                text: "my devices"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }

            Repeater {
                model: panel.mine
                delegate: PanelRow {
                    required property var modelData
                    readonly property bool busy: modelData.state === BluetoothDeviceState.Connecting
                        || modelData.state === BluetoothDeviceState.Disconnecting
                    icon: panel.deviceIcon(modelData)
                    iconColor: modelData.connected ? Theme.blue : Theme.subtle
                    title: panel.label(modelData)
                    active: modelData.connected
                    trailing: busy ? "…"
                        : modelData.connected ? (modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : "connected")
                        : ""
                    hoverText: busy ? "" : (modelData.connected ? "disconnect" : "connect")
                    onClicked: panel.tap(modelData)
                }
            }

            Text {
                visible: panel.nearby.length > 0
                Layout.leftMargin: 8
                Layout.topMargin: 6
                text: "nearby"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }

            Repeater {
                model: panel.nearby
                delegate: PanelRow {
                    required property var modelData
                    icon: panel.deviceIcon(modelData)
                    title: panel.label(modelData)
                    trailing: modelData.pairing ? "pairing…" : ""
                    trailingColor: Theme.peach
                    hoverText: modelData.pairing ? "" : "pair"
                    onClicked: panel.tap(modelData)
                }
            }

            Text {
                visible: panel.mine.length === 0 && panel.nearby.length === 0
                Layout.fillWidth: true
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                horizontalAlignment: Text.AlignHCenter
                text: "searching…"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }
        }
    }
}
