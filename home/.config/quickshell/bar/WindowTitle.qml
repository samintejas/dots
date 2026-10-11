import QtQuick
import Quickshell.Hyprland
import "../theme"

Item {
    id: root

    required property var screen

    readonly property var hyprMonitor: Hyprland.monitorFor(screen)

    property string lastTitle: ""

    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            if (Hyprland.focusedMonitor === root.hyprMonitor) {
                root.lastTitle = Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
            }
        }
    }

    readonly property string rawTitle: {
        if (Hyprland.focusedMonitor === hyprMonitor)
            return Hyprland.activeToplevel ? Hyprland.activeToplevel.title : ""
        return lastTitle
    }

    readonly property string displayTitle: {
        let t = rawTitle
        t = t.replace(/ — Zen Browser$/, "")
        t = t.replace(/ - fish$/, "")
        t = t.replace(/ - nvim$/, "")
        t = t.replace(/ - zsh$/, "")
        if (t === "Ghostty") t = "ghostty"
        if (t.length > 60) t = t.substring(0, 60) + "…"
        return t
    }

    implicitWidth: label.implicitWidth + 16
    implicitHeight: parent.height

    Text {
        id: label
        anchors {
            left: parent.left
            leftMargin: 8
            verticalCenter: parent.verticalCenter
        }
        text: root.displayTitle
        font.family: "GeistMono Nerd Font"
        font.pixelSize: 13
        color: Theme.textDim
        elide: Text.ElideRight
        maximumLineCount: 1
    }
}
