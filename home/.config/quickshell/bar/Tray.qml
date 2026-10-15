import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Hyprland

Item {
    id: root

    property var contextMenu: null

    implicitWidth:  row.implicitWidth + 8
    implicitHeight: 32

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItem
                required property SystemTrayItem modelData

                implicitWidth:  16
                implicitHeight: 16

                Image {
                    anchors.fill: parent
                    source: {
                        const raw = trayItem.modelData.icon
                        // Handle "iconname?path=/some/dir" format (Spotify etc.)
                        if (raw.includes("?path=")) {
                            const parts = raw.split("?path=")
                            const name  = parts[0].split("/").pop()
                            const dir   = parts[1]
                            return dir + "/" + name + ".png"
                        }
                        return raw
                    }
                    smooth: true
                    mipmap: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) {
                            // Find matching toplevel by title and switch to its workspace
                            const itemId = trayItem.modelData.id.toLowerCase()
                            const toplevels = Hyprland.toplevels.values
                            for (let i = 0; i < toplevels.length; i++) {
                                const t = toplevels[i]
                                const title = (t.title || "").toLowerCase()
                                if (title && title.includes(itemId.split(".").pop())) {
                                    if (t.workspace)
                                        Hyprland.dispatch("workspace " + t.workspace.id)
                                    break
                                }
                            }
                            trayItem.modelData.activate()
                        } else if (mouse.button === Qt.RightButton && root.contextMenu) {
                            root.contextMenu.open(trayItem.modelData.menu, trayItem)
                        }
                    }
                }
            }
        }
    }
}
