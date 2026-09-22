import QtQuick
import Quickshell.Io
import "../notifications"

Item {
    id: root

    property bool showFull: false
    property var  now: new Date()

    // Match waybar: "%I:%M %p" / "%a %b %d  %I:%M %p"
    readonly property string timeStr: Qt.formatDateTime(now, showFull ? "ddd MMM dd  hh:mm AP" : "hh:mm AP")

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    implicitWidth:  label.implicitWidth + 16
    implicitHeight: 32

    Text {
        id: label
        anchors.centerIn: parent
        text: root.timeStr
        font.family: "GeistMono Nerd Font"
        font.pixelSize: 13
        color: "#b0b0b0"
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.showFull = !root.showFull
        onDoubleClicked: NotificationDrawerState.toggle()
    }
}
