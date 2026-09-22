import QtQuick
import Quickshell.Io

Item {
    id: root

    property string connType:      "none"
    property int    signalStrength: 0

    readonly property string icon: connType !== "none" ? "󰪥" : "○"

    readonly property color textColor: {
        if (connType === "none")     return "#555555"
        if (connType === "ethernet") return "#ffffff"
        if (signalStrength >= 70)    return "#ffffff"
        if (signalStrength >= 40)    return "#fab387"
        return "#f38ba8"
    }

    function refresh() { netProc.running = true }

    Process {
        id: netProc
        command: ["bash", "-c",
            "if nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q 'ethernet:connected'; then " +
            "  echo 'ethernet 100'; " +
            "elif nmcli -t -f TYPE,STATE dev 2>/dev/null | grep -q 'wifi:connected'; then " +
            "  sig=$(nmcli -t -f SIGNAL,ACTIVE dev wifi 2>/dev/null | awk -F: '/yes$/{print $1}' | head -1); " +
            "  echo \"wifi ${sig:-0}\"; " +
            "else echo 'none 0'; fi"
        ]
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(" ")
                root.connType       = parts[0] || "none"
                root.signalStrength = parseInt(parts[1]) || 0
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()

    implicitWidth:  24
    implicitHeight: 32

    Text {
        id: label
        anchors.centerIn: parent
        text: root.icon
        font.family: "GeistMono Nerd Font"
        font.pixelSize: 16
        color: root.textColor
    }
}
