import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Full-height drawer sliding in from the right edge.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property var tracked: NotificationDrawerState.trackedNotifications
    readonly property var trackedCount: tracked ? tracked.count : 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace:     "notifications-drawer"

    anchors { top: true; bottom: true; right: true }

    color:          "transparent"
    visible:        NotificationDrawerState.visible
    implicitWidth:  overlay.width

    // also track notifications that arrive while drawer is open
    Connections {
        target: NotificationDrawerState.server
        function onNotification(notification) {
            notification.tracked = true
        }
    }

    Item {
        id: overlay
        width: root.screen ? root.screen.width : 1920
        height: root.screen ? root.screen.height : 1080

        // dimmed backdrop
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
            opacity: drawer.x < overlay.drawerW ? 1 - (drawer.x / overlay.drawerW) : 0

            MouseArea {
                anchors.fill: parent
                onClicked: NotificationDrawerState.toggle()
            }
        }

        readonly property int drawerW: 380

        Rectangle {
            id: drawer
            width: overlay.drawerW
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }

            color: "#0a0a0a"
            border.width: 0

            // left border matching hyprland active window border
            Rectangle {
                id: leftBorder
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: 2
                color: "#505050"
                z: 1
            }

            x: NotificationDrawerState.visible ? 0 : overlay.drawerW

            Behavior on x {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // header
            Rectangle {
                id: header
                anchors { top: parent.top; left: leftBorder.right; right: parent.right }
                height: 44
                color: "#111111"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#252525"
                }

                RowLayout {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    spacing: 8

                    Text {
                        text: "DND"
                        font.family: "GeistMono Nerd Font"
                        font.pixelSize: 10
                        font.letterSpacing: 0.5
                        color: "#484848"
                    }

                    Item {
                        width: 34; height: 18

                        Rectangle {
                            anchors.fill: parent
                            radius: 9
                            color: NotificationDrawerState.dnd ? "#89b4fa" : "#252525"
                            Behavior on color { ColorAnimation { duration: 150 } }

                            Rectangle {
                                width: 12; height: 12; radius: 6
                                anchors.verticalCenter: parent.verticalCenter
                                x: NotificationDrawerState.dnd ? parent.width - width - 3 : 3
                                color: NotificationDrawerState.dnd ? "#0a0a0a" : "#686868"
                                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: NotificationDrawerState.dnd = !NotificationDrawerState.dnd
                        }
                    }
                }

                // notification count
                Text {
                    anchors.centerIn: parent
                    text: root.trackedCount
                    font.family: "GeistMono Nerd Font"
                    font.pixelSize: 11
                    color: "#484848"
                    visible: root.trackedCount > 0
                }

                // clear all
                Item {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 14 }
                    width: 24; height: 24
                    visible: root.trackedCount > 0

                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: clearHover.containsMouse ? Qt.rgba(0.85, 0.44, 0.44, 0.12) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "󰎟"
                            font.family: "GeistMono Nerd Font"
                            font.pixelSize: 14
                            color: clearHover.containsMouse ? "#f38ba8" : "#484848"
                        }
                    }

                    MouseArea {
                        id: clearHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (!root.tracked) return
                            for (var i = root.tracked.count - 1; i >= 0; i--) {
                                root.tracked.get(i).dismiss()
                            }
                        }
                    }
                }
            }

            // notification list
            Flickable {
                anchors {
                    top: header.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                contentHeight: notifCol.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: notifCol
                    anchors { left: parent.left; right: parent.right }
                    spacing: 0

                    // empty state
                    Item {
                        width: parent.width
                        height: 80
                        visible: root.trackedCount === 0

                        Text {
                            anchors.centerIn: parent
                            text: "no notifications"
                            font.family: "GeistMono Nerd Font"
                            font.pixelSize: 11
                            color: "#484848"
                        }
                    }

                    Repeater {
                        model: root.tracked

                        delegate: Item {
                            id: drawerDelegate
                            required property var modelData
                            width: notifCol.width
                            implicitHeight: drawerNotiItem.implicitHeight + 8

                            NotificationItem {
                                id: drawerNotiItem
                                anchors {
                                    left: parent.left; right: parent.right
                                    top: parent.top
                                    margins: 8
                                    bottomMargin: 0
                                }
                                notification: drawerDelegate.modelData
                                isPopup: false

                                onClosed: drawerDelegate.modelData.dismiss()
                                onActionInvoked: identifier => {
                                    var actions = drawerDelegate.modelData.actions
                                    for (var i = 0; i < actions.length; i++) {
                                        if (actions[i].identifier === identifier) {
                                            actions[i].invoke()
                                            break
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
