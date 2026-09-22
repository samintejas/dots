import QtQuick
import Quickshell.Services.UPower

// Battery state via UPower over D-Bus — event-driven, no polling and no
// subprocesses. Replaces the previous 5s timer that spawned two `cat`
// processes per tick (~1,400 processes an hour).
Item {
    id: root

    readonly property UPowerDevice device: UPower.displayDevice
    readonly property bool present: device && device.ready && device.isLaptopBattery

    // UPower reports percentage as a 0-1 ratio (verified: reads 1.0 at full).
    readonly property int capacity: present ? Math.round(device.percentage * 100) : 100

    // Charging drives the pulse. FullyCharged is deliberately NOT charging —
    // otherwise the icon pulses forever while plugged in at 100%.
    readonly property bool charging: present && device.state === UPowerDeviceState.Charging
    readonly property bool full: present && device.state === UPowerDeviceState.FullyCharged

    readonly property string icon: "󰪥"

    readonly property color textColor: {
        if (charging)
            return "#a6e3a1";

        if (capacity <= 20)
            return "#f38ba8";

        if (capacity <= 50)
            return "#fab387";

        return "#ffffff";
    }

    // Keyed off `present`, not `visible` — `visible` reads back as effective
    // visibility (parent-dependent), which would collapse the width wrongly.
    visible: present
    implicitWidth: present ? 24 : 0
    implicitHeight: 32

    SequentialAnimation {
        running: root.charging
        loops: Animation.Infinite

        NumberAnimation {
            target: label
            property: "opacity"
            to: 0.3
            duration: 400
            easing.type: Easing.InOutSine
        }

        NumberAnimation {
            target: label
            property: "opacity"
            to: 1
            duration: 400
            easing.type: Easing.InOutSine
        }

        onRunningChanged: if (!running) label.opacity = 1
    }

    Text {
        id: label

        anchors.centerIn: parent
        text: root.icon
        font.family: "GeistMono Nerd Font"
        font.pixelSize: 16
        color: root.textColor
    }
}
