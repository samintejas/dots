import QtQuick
import Quickshell.Services.Mpris
import "../theme"

// Media via MPRIS over D-Bus. Replaces three long-lived `playerctl --follow`
// processes, and is no longer hardcoded to Spotify.
//
// To go back to Spotify-only, filter on dbusName in activePlayer:
//     if (ps[i].dbusName.endsWith(".spotify")) return ps[i]
Item {
    id: root

    // Prefer whatever is actually playing; otherwise fall back to the first
    // player present, so a paused track still shows.
    readonly property MprisPlayer player: {
        if (!Mpris.players)
            return null;

        const ps = Mpris.players.values;
        for (let i = 0; i < ps.length; i++) {
            if (ps[i].isPlaying)
                return ps[i];

        }
        return ps.length > 0 ? ps[0] : null;
    }

    readonly property bool isPlaying: player !== null && player.isPlaying
    readonly property string track: player ? player.trackTitle : ""
    readonly property string artist: player ? player.trackArtist : ""

    readonly property string displayText: {
        if (!track)
            return "";

        const glyph = isPlaying ? "▶" : "⏸";
        let text = glyph + "  " + (artist ? artist + " – " + track : track);
        if (text.length > 48)
            text = text.substring(0, 48) + "…";

        return text;
    }

    visible: displayText !== ""
    implicitWidth: displayText !== "" ? label.implicitWidth + 12 : 0
    implicitHeight: Theme.barHeight

    Text {
        id: label

        anchors.centerIn: parent
        text: root.displayText
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        color: root.isPlaying ? Theme.textDim : Theme.muted
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: mouse => {
            if (!root.player)
                return;

            if (mouse.button === Qt.LeftButton)
                root.player.togglePlaying();
            else if (mouse.button === Qt.RightButton)
                root.player.next();
            else if (mouse.button === Qt.MiddleButton)
                root.player.previous();
        }
        onWheel: wheel => {
            if (!root.player)
                return;

            if (wheel.angleDelta.y > 0)
                root.player.next();
            else
                root.player.previous();
        }
    }
}
