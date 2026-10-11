pragma Singleton
import QtQuick

// What the on-screen display currently shows.
QtObject {
    property bool visible: false
    property string label: ""      // "volume" | "brightness"
    property int percent: 0
    property bool muted: false

    function show(label, percent, muted) {
        this.label = label
        this.percent = percent
        this.muted = muted === true
        visible = true
        hideTimer.restart()
    }

    property Timer hideTimer: Timer {
        interval: 1400
        onTriggered: OsdState.visible = false
    }
}
