import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import "../theme"

// Output volume via PipeWire. Same single glyph as the other status items:
// filled while audible, hollow while muted. Scroll = +/-5%, click = mute,
// right-click = mixer.
Item {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.audio !== null
    readonly property bool muted: ready && sink.audio.muted
    readonly property int percent: ready ? Math.round(sink.audio.volume * 100) : 0

    PwObjectTracker {
        objects: [root.sink]
    }

    visible: ready
    implicitWidth: ready ? 24 : 0
    implicitHeight: Theme.barHeight

    Hint {
        target: root
        text: root.muted ? "muted" : "volume " + root.percent + "%"
    }

    Text {
        anchors.centerIn: parent
        text: root.muted ? "○" : "󰪥"
        font.family: Theme.font
        font.pixelSize: Theme.iconSize
        color: root.muted ? Theme.dim : (root.percent > 100 ? Theme.peach : Theme.textMax)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (!root.ready)
                return;

            if (mouse.button === Qt.RightButton)
                Quickshell.execDetached(["ghostty", "-e", "wiremix"]);
            else
                root.sink.audio.muted = !root.sink.audio.muted;
        }
        onWheel: wheel => {
            if (!root.ready)
                return;

            const step = wheel.angleDelta.y > 0 ? 0.05 : -0.05;
            root.sink.audio.muted = false;
            root.sink.audio.volume = Math.max(0, Math.min(1.5, root.sink.audio.volume + step));
        }
    }
}
