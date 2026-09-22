import QtQuick
import Quickshell.Io

Item {
    id: root

    property bool powered:   false
    property bool connected: false

    readonly property string icon: connected ? "󰪥" : "○"

    readonly property color textColor: connected ? "#89b4fa" : "#555555"

    function refresh() {
        poweredProc.running   = true
        connectedProc.running = true
    }

    Process {
        id: poweredProc
        command: ["bash", "-c", "bluetoothctl show 2>/dev/null | grep -c 'Powered: yes'"]
        stdout: SplitParser {
            onRead: data => root.powered = parseInt(data.trim()) > 0
        }
    }

    Process {
        id: connectedProc
        command: ["bash", "-c", "bluetoothctl devices Connected 2>/dev/null | wc -l"]
        stdout: SplitParser {
            onRead: data => root.connected = parseInt(data.trim()) > 0
        }
    }

    Process {
        id: btLaunch
        command: ["ghostty", "-e", "bluetoothctl"]
    }

    Timer {
        interval: 15000
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

    MouseArea {
        anchors.fill: parent
        onClicked: btLaunch.running = true
    }
}
