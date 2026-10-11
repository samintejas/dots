pragma Singleton
import QtQuick

// Which bar popover is open, and on which screen. One at a time, like the
// macOS menu bar: opening another panel closes the current one.
QtObject {
    id: root

    property string current: ""      // "", "network", "bluetooth"
    property string screenName: ""
    property double closedAt: 0      // ms; swallows the click that dismissed a panel

    property bool grab: true         // false when opened over IPC: no input serial to grab with

    function toggle(name, screen, viaClick) {
        grab = viaClick !== false
        const sn = screen ? screen.name : ""
        if (current === name && screenName === sn) {
            close()
            return
        }
        // the click that just dismissed this panel (focus grab) must not reopen it
        if (current === "" && Date.now() - closedAt < 200 && screenName === sn && lastName === name)
            return
        current = name
        screenName = sn
    }

    property string lastName: ""

    function close() {
        if (current !== "") {
            lastName = current
            closedAt = Date.now()
        }
        current = ""
    }
}
