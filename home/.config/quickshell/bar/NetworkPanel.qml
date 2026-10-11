import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "../theme"

// Wi-Fi popover, macOS style: switch in the header, networks by signal, the
// joined one on top. Click to join; secured unknown networks ask for a password.
PopoverPanel {
    id: panel

    required property var wifiDevice
    required property var wiredDevice

    name: "network"
    title: "wi-fi"
    checked: Networking.wifiEnabled
    onToggled: value => Networking.wifiEnabled = value

    // network currently asking for a password, and the last error to show
    property var pending: null
    property string error: ""

    onVisibleChanged: {
        if (wifiDevice)
            wifiDevice.scannerEnabled = visible
        if (!visible) {
            pending = null
            error = ""
        }
    }

    readonly property var networks: {
        if (!wifiDevice || !wifiDevice.networks)
            return []
        const seen = {}
        const out = []
        const ns = wifiDevice.networks.values
        for (let i = 0; i < ns.length; i++) {
            const n = ns[i]
            if (!n.name || seen[n.name])
                continue
            seen[n.name] = true
            out.push(n)
        }
        out.sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
        return out
    }

    function glyph(cp) { return String.fromCodePoint(cp) }

    function wifiIcon(strength) {
        return glyph(strength > 0.75 ? 0xF0928 : strength > 0.5 ? 0xF0925 : strength > 0.25 ? 0xF0922 : 0xF091F)
    }

    function isOpen(n) {
        return n.security === WifiSecurityType.Open || n.security === WifiSecurityType.Owe
    }

    function join(n) {
        error = ""
        if (n.known || isOpen(n)) {
            pending = null
            n.connect()
        } else {
            pending = n
        }
    }

    // wired link
    PanelRow {
        visible: panel.wiredDevice !== null
        icon: panel.glyph(0xF0200)
        iconColor: panel.wiredDevice && panel.wiredDevice.connected ? Theme.textMax : Theme.dim
        title: "ethernet"
        active: panel.wiredDevice !== null && panel.wiredDevice.connected
        trailing: panel.wiredDevice && panel.wiredDevice.connected ? "connected" : "not connected"
    }

    Rectangle {
        visible: panel.wiredDevice !== null
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.topMargin: 2
        Layout.bottomMargin: 2
        color: Theme.border
    }

    Text {
        visible: !Networking.wifiEnabled || !panel.wifiDevice
        Layout.fillWidth: true
        Layout.topMargin: 12
        Layout.bottomMargin: 12
        horizontalAlignment: Text.AlignHCenter
        text: !panel.wifiDevice ? "no wi-fi adapter" : "wi-fi is off"
        font.family: Theme.font
        font.pixelSize: 12
        color: Theme.subtle
    }

    Text {
        visible: Networking.wifiEnabled && panel.wifiDevice && panel.networks.length === 0
        Layout.fillWidth: true
        Layout.topMargin: 12
        Layout.bottomMargin: 12
        horizontalAlignment: Text.AlignHCenter
        text: "scanning…"
        font.family: Theme.font
        font.pixelSize: 12
        color: Theme.subtle
    }

    Flickable {
        id: scroller
        visible: Networking.wifiEnabled && panel.networks.length > 0
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(list.implicitHeight, 320)
        contentHeight: list.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: list
            width: scroller.width
            spacing: 2

            Repeater {
                model: panel.networks

                delegate: ColumnLayout {
                    id: item

                    required property var modelData
                    readonly property bool asking: panel.pending === modelData
                    readonly property bool connecting: modelData.state === ConnectionState.Connecting

                    Layout.fillWidth: true
                    spacing: 2

                    Connections {
                        target: item.modelData
                        function onConnectionFailed(reason) {
                            if (reason === ConnectionFailReason.NoSecrets) {
                                panel.pending = item.modelData
                            } else {
                                panel.error = "error: couldn't join " + item.modelData.name.toLowerCase()
                                panel.pending = item.modelData
                            }
                        }
                    }

                    PanelRow {
                        icon: panel.wifiIcon(item.modelData.signalStrength)
                        iconColor: item.modelData.connected ? Theme.textMax : Theme.subtle
                        title: item.modelData.name
                        active: item.modelData.connected
                        trailing: item.connecting ? "connecting…"
                            : item.modelData.connected ? "connected"
                            : (!panel.isOpen(item.modelData) ? panel.glyph(0xF033E) : "")
                        trailingColor: item.connecting ? Theme.peach : Theme.subtle
                        hoverText: item.modelData.connected ? "disconnect" : ""
                        onClicked: {
                            if (item.modelData.connected)
                                item.modelData.disconnect()
                            else
                                panel.join(item.modelData)
                        }
                    }

                    // inline password prompt
                    Rectangle {
                        visible: item.asking
                        Layout.fillWidth: true
                        Layout.leftMargin: 36
                        Layout.rightMargin: 4
                        Layout.bottomMargin: 4
                        Layout.preferredHeight: 28
                        radius: Theme.radiusSm
                        color: "#000000"
                        border.width: pass.activeFocus ? 2 : 1
                        border.color: pass.activeFocus ? Qt.rgba(239 / 255, 156 / 255, 216 / 255, 0.55) : Theme.borderRaised

                        TextInput {
                            id: pass
                            anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Theme.textHi
                            selectionColor: Theme.pink
                            selectedTextColor: Theme.base
                            clip: true
                            onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                            Keys.onReturnPressed: submit()
                            Keys.onEnterPressed: submit()
                            Keys.onEscapePressed: panel.pending = null

                            function submit() {
                                if (text.length === 0) return
                                panel.error = ""
                                item.modelData.connectWithPsk(text)
                                panel.pending = null
                            }

                            Text {
                                visible: pass.text === ""
                                anchors.verticalCenter: parent.verticalCenter
                                text: "password"
                                font: pass.font
                                color: Theme.muted
                            }
                        }
                    }

                    Text {
                        visible: item.asking && panel.error !== ""
                        Layout.leftMargin: 36
                        Layout.bottomMargin: 4
                        text: panel.error
                        font.family: Theme.font
                        font.pixelSize: 11
                        color: Theme.red
                    }
                }
            }
        }
    }
}
