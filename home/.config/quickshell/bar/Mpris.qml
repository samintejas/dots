import QtQuick
import Quickshell.Io

Item {
    id: root

    property string status: ""   // "Playing" | "Paused" | ""
    property string artist: ""
    property string track:  ""

    readonly property bool isPlaying: status === "Playing"
    readonly property bool isPaused:  status === "Paused"

    readonly property string displayText: {
        if (!track) return ""
        const icon = isPlaying ? "▶" : (isPaused ? "⏸" : "")
        let text = icon + "  " + (artist ? artist + " – " + track : track)
        if (text.length > 48) text = text.substring(0, 48) + "…"
        return text
    }

    // Follow playback status changes (event-driven, no polling)
    Process {
        id: statusFollow
        command: ["playerctl", "-p", "spotify", "-F", "status"]
        running: true
        stdout: SplitParser {
            onRead: data => root.status = data.trim()
        }
        onExited: (code) => {
            if (code !== 0) root.status = ""
            // Restart if playerctl exits (e.g. Spotify not running yet)
            restartTimer.running = true
        }
    }

    // Follow metadata changes
    Process {
        id: metaFollow
        command: ["playerctl", "-p", "spotify", "-F", "metadata", "--format",
                  "{{artist}}|||{{title}}"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split("|||")
                root.artist = parts[0] || ""
                root.track  = parts[1] || ""
            }
        }
        onExited: (code) => {
            if (code !== 0) { root.artist = ""; root.track = "" }
        }
    }

    // Retry if Spotify wasn't running when bar started
    Timer {
        id: restartTimer
        interval: 5000
        running: false
        repeat: false
        onTriggered: {
            statusFollow.running = true
            metaFollow.running = true
        }
    }

    visible: displayText !== ""
    implicitWidth:  visible ? label.implicitWidth + 12 : 0
    implicitHeight: 32

    Text {
        id: label
        anchors.centerIn: parent
        text: root.displayText
        font.family: "GeistMono Nerd Font"
        font.pixelSize: 13
        color: root.isPlaying ? "#9a9a9a" : "#606060"
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton)
                playPause.running = true
            else if (mouse.button === Qt.RightButton)
                nextTrack.running = true
            else if (mouse.button === Qt.MiddleButton)
                prevTrack.running = true
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) nextTrack.running = true
            else                        prevTrack.running = true
        }
    }

    Process { id: playPause; command: ["playerctl", "-p", "spotify", "play-pause"] }
    Process { id: nextTrack; command: ["playerctl", "-p", "spotify", "next"] }
    Process { id: prevTrack; command: ["playerctl", "-p", "spotify", "previous"] }
}
