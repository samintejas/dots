import QtQuick
import QtQml
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// Floating popup notifications — top-right, stacked vertically.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // plain JS array of Notification objects — avoids id-lookup timing races
    property var popups: []

    // active dismissal timers, one per notification: [{ notif, timer }]
    property var dismissTimers: []

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace:     "notifications-popup"

    anchors { bottom: true; right: true }
    margins.bottom: 20
    margins.right:  20

    color:          "transparent"
    implicitWidth:  360
    implicitHeight: popupCol.implicitHeight
    visible:        popups.length > 0

    function addPopup(notif) {
        if (root.popups.indexOf(notif) >= 0) return
        var arr = root.popups.slice()
        arr.push(notif)
        root.popups = arr
    }

    function removePopup(notif) {
        var idx = root.popups.indexOf(notif)
        if (idx < 0) return
        var arr = root.popups.slice()
        arr.splice(idx, 1)
        root.popups = arr
    }

    function showPopup(notif) {
        if (!notif) return
        if (NotificationDrawerState.dnd) return
        if (NotificationDrawerState.visible) return

        notif.tracked = true
        root.addPopup(notif)

        var timeout = notif.expireTimeout > 0
            ? notif.expireTimeout
            : (notif.urgency === NotificationUrgency.Critical ? 0 : 5000)
        root.scheduleDismiss(notif, timeout)
    }

    function scheduleDismiss(notif, timeout) {
        // cancel any existing timer for this notification
        for (var i = 0; i < root.dismissTimers.length; i++) {
            if (root.dismissTimers[i].notif === notif) {
                root.dismissTimers[i].timer.destroy()
                root.dismissTimers.splice(i, 1)
                break
            }
        }
        if (timeout <= 0) return
        var t = dismissTimerComp.createObject(root, {
            notif: notif,
            interval: timeout
        })
        root.dismissTimers.push({ notif: notif, timer: t })
    }

    function cancelDismiss(notif) {
        for (var i = 0; i < root.dismissTimers.length; i++) {
            if (root.dismissTimers[i].notif === notif) {
                root.dismissTimers[i].timer.destroy()
                root.dismissTimers.splice(i, 1)
                return
            }
        }
    }

    // brand-new notifications
    Connections {
        target: NotificationDrawerState.server

        function onNotification(notification) {
            root.showPopup(notification)
        }
    }

    // watch tracked notifications for in-place updates (replaces_id), which
    // do not re-emit `notification`. Fires showPopup again on any meaningful
    // property change — handles spotify track changes, nm/bluez status, etc.
    Instantiator {
        model: NotificationDrawerState.trackedNotifications

        delegate: QtObject {
            id: watcher
            required property var modelData

            property string lastSummary: modelData ? modelData.summary : ""
            property string lastBody:    modelData ? modelData.body    : ""
            property string lastImage:   modelData ? modelData.image   : ""

            function checkChanged() {
                if (!modelData) return
                if (modelData.summary === lastSummary
                    && modelData.body    === lastBody
                    && modelData.image   === lastImage) return

                lastSummary = modelData.summary
                lastBody    = modelData.body
                lastImage   = modelData.image

                root.showPopup(modelData)
            }

            property var _conn: Connections {
                target: watcher.modelData
                function onSummaryChanged() { watcher.checkChanged() }
                function onBodyChanged()    { watcher.checkChanged() }
                function onImageChanged()   { watcher.checkChanged() }
            }

            Component.onDestruction: {
                if (modelData) {
                    root.removePopup(modelData)
                    root.cancelDismiss(modelData)
                }
            }
        }
    }

    Component {
        id: dismissTimerComp
        Timer {
            property var notif
            running: true
            repeat: false
            onTriggered: {
                root.removePopup(notif)
                for (var i = 0; i < root.dismissTimers.length; i++) {
                    if (root.dismissTimers[i].timer === this) {
                        root.dismissTimers.splice(i, 1)
                        break
                    }
                }
                destroy()
            }
        }
    }

    Column {
        id: popupCol
        anchors { left: parent.left; right: parent.right }
        spacing: 6

        Repeater {
            model: root.popups

            delegate: Item {
                id: popupDelegate
                required property int index
                required property var modelData

                readonly property var notif: modelData

                width: popupCol.width
                implicitHeight: notiItem.implicitHeight
                opacity: 0
                x: 40

                NotificationItem {
                    id: notiItem
                    anchors { left: parent.left; right: parent.right }
                    notification: popupDelegate.notif
                    isPopup: true

                    onClosed: {
                        if (popupDelegate.notif) popupDelegate.notif.dismiss()
                        root.removePopup(popupDelegate.notif)
                        root.cancelDismiss(popupDelegate.notif)
                    }
                    onActionInvoked: identifier => {
                        if (popupDelegate.notif) {
                            var actions = popupDelegate.notif.actions
                            for (var i = 0; i < actions.length; i++) {
                                if (actions[i].identifier === identifier) {
                                    actions[i].invoke()
                                    break
                                }
                            }
                        }
                        root.removePopup(popupDelegate.notif)
                        root.cancelDismiss(popupDelegate.notif)
                    }
                }

                Component.onCompleted: slideIn.start()

                ParallelAnimation {
                    id: slideIn
                    NumberAnimation { target: popupDelegate; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutCubic }
                    NumberAnimation { target: popupDelegate; property: "x"; to: 0; duration: 200; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
