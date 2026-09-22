pragma Singleton
import QtQuick

QtObject {
    property bool visible: false
    property bool dnd: false
    property var trackedNotifications: null
    property var server: null

    function toggle() {
        visible = !visible
    }
}
