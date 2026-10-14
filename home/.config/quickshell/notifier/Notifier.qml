import QtQuick
import Quickshell
import Quickshell.Networking
import Quickshell.Services.Mpris
import Quickshell.Services.UPower

// System event notifications, from state the shell already watches. Replaces
// the notify-battery / notify-network / notify-spotify shell loops: no extra
// processes, no `upower --monitor` or `nmcli monitor` to babysit.
// Delivery goes through notify-send so the toasts take the normal path
// (popup, drawer, repeat collapsing).
Scope {
    id: root

    // nothing fires until the first readings are in, so a shell restart is silent
    property bool primed: false

    Timer {
        interval: 4000
        running: true
        onTriggered: {
            root.primed = true
            root.lastBatteryState = root.battery ? root.battery.state : -1
            root.lastSsid = root.ssid
        }
    }

    function notify(app, urgency, summary, body, extra) {
        const args = ["notify-send", "--app-name=" + app, "--urgency=" + urgency];
        if (extra) extra.forEach(a => args.push(a));
        args.push(summary, body);
        Quickshell.execDetached(args);
    }

    // ---- battery ---------------------------------------------------------
    readonly property UPowerDevice battery: UPower.displayDevice
    readonly property bool hasBattery: battery && battery.ready && battery.isLaptopBattery
    readonly property int pct: hasBattery ? Math.round(battery.percentage * 100) : 100
    property int lastBatteryState: -1
    property string warned: ""        // "", "low", "crit"

    function onBattery() {
        if (!primed || !hasBattery) return;
        const st = battery.state;
        if (st !== lastBatteryState) {
            if (st === UPowerDeviceState.Charging) {
                notify("battery", "low", "charging", "battery at " + pct + "%");
                warned = "";
            } else if (st === UPowerDeviceState.Discharging && lastBatteryState === UPowerDeviceState.Charging) {
                notify("battery", "normal", "charging stopped", "unplugged at " + pct + "% — not full");
            } else if (st === UPowerDeviceState.FullyCharged) {
                notify("battery", "low", "fully charged", "battery at 100%");
            }
            lastBatteryState = st;
        }

        if (st === UPowerDeviceState.Discharging) {
            if (pct <= 5 && warned !== "crit") {
                notify("battery", "critical", "battery critical", pct + "% — plug in now");
                warned = "crit";
            } else if (pct <= 15 && warned === "") {
                notify("battery", "normal", "battery low", pct + "% remaining");
                warned = "low";
            }
        } else {
            warned = "";
        }
    }

    Connections {
        target: root.battery
        function onStateChanged() { root.onBattery() }
        function onPercentageChanged() { root.onBattery() }
    }

    // ---- wi-fi -----------------------------------------------------------
    readonly property string ssid: {
        const ds = Networking.devices.values;
        for (let i = 0; i < ds.length; i++) {
            if (ds[i].type !== DeviceType.Wifi || !ds[i].networks) continue;
            const ns = ds[i].networks.values;
            for (let j = 0; j < ns.length; j++) {
                if (ns[j].connected) return ns[j].name;
            }
        }
        return "";
    }
    property string lastSsid: ""

    onSsidChanged: {
        if (!primed) return;
        if (ssid !== "")
            notify("network", "low", "wi-fi connected", ssid);
        else if (lastSsid !== "")
            notify("network", "normal", "wi-fi disconnected", "was: " + lastSsid);
        lastSsid = ssid;
    }

    // ---- spotify track change ---------------------------------------------
    readonly property var spotify: {
        const ps = Mpris.players ? Mpris.players.values : [];
        for (let i = 0; i < ps.length; i++) {
            if ((ps[i].identity || "").toLowerCase() === "spotify") return ps[i];
        }
        return null;
    }

    // The title lands before the cover does, so reading the art in
    // onTrackTitleChanged shows the previous track's. Wait for the whole
    // track to settle, then read everything at once.
    property string lastTrack: ""

    Timer {
        id: trackSettle
        interval: 300
        onTriggered: {
            const p = root.spotify;
            if (!root.primed || !p || !p.trackTitle) return;
            const key = p.trackTitle + "\n" + p.trackArtist + "\n" + p.trackAlbum;
            if (key === root.lastTrack) return;
            root.lastTrack = key;
            const extra = ["--expire-time=4000", "--category=x-gnome.music"];
            if (p.trackArtUrl) extra.push("--icon=" + p.trackArtUrl);
            root.notify("Spotify", "low", "♪ " + p.trackTitle, p.trackArtist + " — " + p.trackAlbum, extra);
        }
    }

    Connections {
        target: root.spotify
        function onPostTrackChanged() { trackSettle.restart() }
        function onTrackArtUrlChanged() { trackSettle.restart() }
    }
}
