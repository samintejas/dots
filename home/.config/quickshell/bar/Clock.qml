import QtQuick
import Quickshell.Io
import "../notifications"
import "../theme"

Item {
    id: root

    property bool showFull: false
    property var  now: new Date()

    // lowercase, no uppercase meridiem (Dots: no uppercase)
    readonly property string timeStr: Qt.formatDateTime(now, showFull ? "ddd MMM dd  hh:mm ap" : "hh:mm ap")

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
        font.family: Theme.font
        font.pixelSize: 13
        color: Theme.text
    }

    Hint {
        target: root
        text: Qt.formatDateTime(root.now, "dddd, d MMMM yyyy").toLowerCase()
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton)
                NotificationDrawerState.dnd = !NotificationDrawerState.dnd
            else
                root.showFull = !root.showFull
        }
        onDoubleClicked: NotificationDrawerState.toggle()
    }
}
