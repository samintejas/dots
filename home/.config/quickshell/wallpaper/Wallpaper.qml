import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"

// Background layer — renders the current wallpaper from the local disk cache.
PanelWindow {
    id: root

    required property var modelData

    screen: modelData

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "wallpaper"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: Theme.base

    Image {
        id: img

        anchors.fill: parent
        source: WallpaperState.currentPath
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false // path is stable; the ?v= query is what busts the cache
        smooth: true
        mipmap: true

        // Drives the fade. The previous version animated `opacity` but toggled
        // `visible` instead, so the Behavior never actually ran.
        opacity: status === Image.Ready ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.InOutQuad
            }
        }
    }
}
