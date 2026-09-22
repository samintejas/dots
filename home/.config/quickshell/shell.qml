//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "./bar"
import "./notifications"
import "./wallpaper"

ShellRoot {
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
}
