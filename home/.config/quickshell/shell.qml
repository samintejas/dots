//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import "./theme"
import "./bar"
import "./notifications"
import "./wallpaper"
import "./clipboard"
import "./launcher"
import "./power"
import "./quickchat"
import "./notifier"
import "./osd"

ShellRoot {
    id: root

    function showVolume() {
        const a = Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        if (a) OsdState.show("volume", Math.round(a.volume * 100), a.muted)
    }

    Notifier {}

    NotificationServer {
        id: notifServer
        keepOnReload: true
        actionsSupported: true
        imageSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        persistenceSupported: true
    }

    Scope {
        property bool _init: {
            NotificationDrawerState.server = notifServer
            NotificationDrawerState.trackedNotifications = notifServer.trackedNotifications
            return true
        }
    }

    IpcHandler {
        target: "wallpaper"
        function toggle(): void {
            WallpaperState.toggle()
        }
        function show(): void {
            WallpaperState.visible = true
            if (WallpaperState.results.length === 0) WallpaperState.fetchPage(1)
        }
        function hide(): void {
            WallpaperState.visible = false
        }
    }

    IpcHandler {
        target: "panels"
        function toggle(name: string): void {
            const m = Hyprland.focusedMonitor
            PanelState.toggle(name, { name: m ? m.name : Quickshell.screens[0].name }, false)
        }
        function close(): void { PanelState.close() }
    }

    IpcHandler {
        target: "notifications"
        function toggle(): void { NotificationDrawerState.toggle() }
        function dnd(): void { NotificationDrawerState.toggleDnd() }
        function clear(): void { NotificationDrawerState.clearAll() }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void { LauncherState.toggle("apps") }
        function windows(): void { LauncherState.toggle("windows") }
    }

    IpcHandler {
        target: "quickchat"
        function toggle(): void { QuickChatState.toggle() }
        function ask(question: string): void { QuickChatState.ask(question) }
    }

    IpcHandler {
        target: "power"
        function toggle(): void { PowerState.toggle() }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void { ClipboardState.toggle() }
    }

    // Volume: observe PipeWire so keys, the bar and the mixer all show the OSD.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Connections {
        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
        enabled: osdArmed.armed
        function onVolumeChanged() { root.showVolume() }
        function onMutedChanged() { root.showVolume() }
    }

    // ignore the values PipeWire reports while it settles at startup
    Timer {
        id: osdArmed
        property bool armed: false
        interval: 2000
        running: true
        onTriggered: armed = true
    }

    // Brightness: Hyprland binds call `qs ipc call osd brightness` after
    // changing it; read the new value back from brightnessctl.
    IpcHandler {
        target: "osd"
        function brightness(): void { brightnessProc.running = true }
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",")
                if (f.length >= 4) OsdState.show("brightness", parseInt(f[3]), false)
            }
        }
    }

    Variants {
        model: Quickshell.screens
        Wallpaper {}
    }

    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Variants {
        model: Quickshell.screens
        NotificationPopup {}
    }

    Variants {
        model: Quickshell.screens
        NotificationDrawer {}
    }

    Variants {
        model: Quickshell.screens
        WallpaperDrawer {}
    }

    Variants {
        model: Quickshell.screens
        ClipboardPanel {}
    }

    Variants {
        model: Quickshell.screens
        LauncherPanel {}
    }

    Variants {
        model: Quickshell.screens
        PanelDismiss {}
    }

    Variants {
        model: Quickshell.screens
        PowerMenu {}
    }

    Variants {
        model: Quickshell.screens
        QuickChatPanel {}
    }

    Variants {
        model: Quickshell.screens
        Osd {}
    }
}
