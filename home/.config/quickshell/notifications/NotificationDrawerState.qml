pragma Singleton
import QtQuick

QtObject {
    property bool visible: false
    property bool dnd: false
    property var trackedNotifications: null
    property var server: null

    signal cleared()

    readonly property int count: (trackedNotifications && trackedNotifications.values) ? trackedNotifications.values.length : 0

    function toggle() {
        visible = !visible
    }

    function toggleDnd() {
        dnd = !dnd
    }

    function clearAll() {
        cleared()
        if (!trackedNotifications) return
        const all = trackedNotifications.values.slice()
        for (var i = 0; i < all.length; i++)
            all[i].dismiss()
    }
}
