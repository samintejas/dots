import QtQuick
import Quickshell
import Quickshell.Wayland

// Background layer — renders the current wallpaper.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer:         WlrLayer.Background
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace:     "wallpaper"

    anchors { top: true; bottom: true; left: true; right: true }
    color: "#0a0a0a"

    Image {
        id: img
        anchors.fill: parent
        source: WallpaperState.currentUrl
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        smooth: true
        mipmap: true
        visible: status === Image.Ready

        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
    }
}
