import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var modelData

    screen: modelData
    color: "#0a0a0a"
    implicitHeight: 32
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: implicitHeight
    WlrLayershell.namespace: "quickshell-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    // Per-screen tray context menu overlay
    TrayMenu {
        id: trayMenu

        screen: root.screen
    }

    RowLayout {
        anchors.fill: parent
        spacing: 4

        // Left
        Workspaces {
            screen: root.screen
        }

        WindowTitle {
            screen: root.screen
        }

        Item {
            Layout.fillWidth: true
        }

        // Right
        Mpris {
        }

        Item {
            implicitWidth: 8
        }

        Tray {
            contextMenu: trayMenu
        }

        Item {
            implicitWidth: 8
        }

        Bluetooth {
        }

        Network {
        }

        Battery {
        }

        Item {
            implicitWidth: 8
        }

        Clock {
        }

    }

}
