import QtQuick
import QtQml
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../theme"

// Floating popup notifications — top-right, stacked vertically.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // plain JS array of Notification objects — avoids id-lookup timing races
    property var popups: []

    // active dismissal timers, one per notification: [{ notif, timer }]
    property var dismissTimers: []

    // the card under the pointer keeps its timer paused
    property var hoveredNotif: null
    readonly property int maxVisible: 3
    readonly property var visiblePopups: popups.slice(-maxVisible)
    readonly property int hiddenCount: Math.max(0, popups.length - maxVisible)

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace:     "notifications-popup"

    anchors { bottom: true; right: true }
    margins.bottom: 20
    margins.right:  20

    color:          "transparent"
    implicitWidth:  360
    implicitHeight: popupCol.implicitHeight + (hiddenCount > 0 ? 22 : 0)
    visible:        popups.length > 0

    // "clear all" in the drawer also drops every popup
    Connections {
        target: NotificationDrawerState
        function onCleared() {
            for (var i = 0; i < root.dismissTimers.length; i++)
                root.dismissTimers[i].timer.destroy()
            root.dismissTimers = []
            root.popups = []
            root.hoveredNotif = null
        }
    }

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

        // a repeat (same app, summary and body) replaces the earlier one
        // instead of stacking: the old popup and its drawer entry go away
        for (var i = root.popups.length - 1; i >= 0; i--) {
            var old = root.popups[i]
            if (old !== notif && old.appName === notif.appName
                && old.summary === notif.summary && old.body === notif.body) {
                root.removePopup(old)
                root.cancelDismiss(old)
                old.dismiss()
            }
        }
        root.addPopup(notif)

        // critical popups stay longer but still leave; they remain in the drawer
        var timeout = notif.expireTimeout > 0
            ? notif.expireTimeout
            : (notif.urgency === NotificationUrgency.Critical ? 20000 : 5000)
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
            running: root.hoveredNotif !== notif
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
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        spacing: 6

        Text {
            visible: root.hiddenCount > 0
            width: parent.width
            horizontalAlignment: Text.AlignRight
            text: "+" + root.hiddenCount + " more"
            font.family: Theme.font
            font.pixelSize: 11
            color: Theme.subtle
        }

        Repeater {
            model: root.visiblePopups

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

                    onHoveredChanged: {
                        if (hovered) root.hoveredNotif = popupDelegate.notif
                        else if (root.hoveredNotif === popupDelegate.notif) root.hoveredNotif = null
                    }

                    onActivated: {
                        if (popupDelegate.notif) {
                            var actions = popupDelegate.notif.actions
                            for (var i = 0; i < actions.length; i++) {
                                if (actions[i].identifier === "default") {
                                    actions[i].invoke()
                                    break
                                }
                            }
                        }
                        root.removePopup(popupDelegate.notif)
                        root.cancelDismiss(popupDelegate.notif)
                    }

                    onClosed: {
                        // drop the popup first: dismiss() tears this delegate down
                        var n = popupDelegate.notif
                        root.removePopup(n)
                        root.cancelDismiss(n)
                        if (n) n.dismiss()
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
                    NumberAnimation { target: popupDelegate; property: "opacity"; to: 1; duration: Theme.dur; easing.type: Easing.OutQuint }
                    NumberAnimation { target: popupDelegate; property: "x"; to: 0; duration: Theme.dur; easing.type: Easing.OutQuint }
                }
            }
        }
    }
}
