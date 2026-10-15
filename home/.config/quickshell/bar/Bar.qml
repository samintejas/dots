import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

PanelWindow {
    id: root

    required property var modelData

    screen: modelData
    color: Theme.base
    implicitHeight: 32
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: implicitHeight
    WlrLayershell.namespace: "quickshell-bar"

    anchors {
        top: true
        left: true
        right: true
    }

    // Tray context menu, anchored under the clicked icon
    TrayMenu {
        id: trayMenu
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

        Volume {
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

        Dnd {
        }

        Clock {
        }

    }

}
