import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

// Full-height drawer sliding in from the right edge.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    readonly property var tracked: NotificationDrawerState.trackedNotifications
    readonly property int trackedCount: (tracked && tracked.values) ? tracked.values.length : 0

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace:     "notifications-drawer"
    WlrLayershell.keyboardFocus: NotificationDrawerState.visible ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

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

        focus: NotificationDrawerState.visible
        Keys.onEscapePressed: NotificationDrawerState.visible = false

        // scrim: click outside to close
        Rectangle {
            anchors.fill: parent
            color: Theme.scrim
            opacity: drawer.x < overlay.drawerW ? 1 - (drawer.x / overlay.drawerW) : 0

            MouseArea {
                anchors.fill: parent
                onClicked: NotificationDrawerState.visible = false
            }
        }

        readonly property int drawerW: 360   // sheet-w

        // Sheet: same ground as the bar; the left hairline is the only edge
        Rectangle {
            id: drawer
            width: overlay.drawerW
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }

            color: Theme.base

            Rectangle {
                id: leftBorder
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: 2                      // same as the Hyprland window border
                color: Theme.line             // = Hyprland active_border #4e4e4e
                z: 1
            }

            x: NotificationDrawerState.visible ? 0 : overlay.drawerW

            Behavior on x {
                NumberAnimation { duration: Theme.dur; easing.type: Easing.OutQuint }
            }

            MouseArea { anchors.fill: parent }   // absorb clicks

            // header: title + count, dnd switch, clear all
            Item {
                id: header
                anchors { top: parent.top; left: leftBorder.right; right: parent.right }
                height: 40

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    text: "notifications" + (root.trackedCount > 0 ? "  " + root.trackedCount : "")
                    font.family: Theme.font
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Theme.textHi
                }

                RowLayout {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 10 }
                    spacing: 10

                    // clear all: ghost button, verb + object
                    Rectangle {
                        enabled: root.trackedCount > 0
                        opacity: enabled ? 1 : 0.4
                        Layout.preferredHeight: 24
                        Layout.preferredWidth: clearLabel.implicitWidth + 20
                        radius: Theme.radiusSm
                        color: clearArea.containsMouse ? Theme.hover : "transparent"
                        border.width: 1
                        border.color: Theme.borderRaised

                        Text {
                            id: clearLabel
                            anchors.centerIn: parent
                            text: "clear all"
                            font.family: Theme.font
                            font.pixelSize: 11
                            color: clearArea.containsMouse ? Theme.textHi : Theme.text
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: NotificationDrawerState.clearAll()
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
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Theme.subtle
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
                                onActivated: {
                                    var actions = drawerDelegate.modelData.actions
                                    for (var i = 0; i < actions.length; i++) {
                                        if (actions[i].identifier === "default") {
                                            actions[i].invoke()
                                            break
                                        }
                                    }
                                }
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
