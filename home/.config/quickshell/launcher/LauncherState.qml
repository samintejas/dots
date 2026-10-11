pragma Singleton
import QtQuick

QtObject {
    property bool visible: false
    property string mode: "apps"    // "apps" | "windows"

    function toggle(m) {
        const next = m || "apps"
        if (visible && mode === next) {
            visible = false
        } else {
            mode = next
            visible = true
        }
    }
}
