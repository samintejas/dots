import QtQuick
import "../notifications"
import "../theme"

// Shown only while do-not-disturb is on. Middle-click the clock to toggle it.
Item {
    visible: NotificationDrawerState.dnd
    implicitWidth: visible ? label.implicitWidth + 12 : 0
    implicitHeight: Theme.barHeight

    Text {
        id: label
        anchors.centerIn: parent
        text: "dnd"
        font.family: Theme.font
        font.pixelSize: 12
        color: Theme.subtle
    }
}
