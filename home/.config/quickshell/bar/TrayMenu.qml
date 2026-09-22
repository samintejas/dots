import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Custom styled tray context menu.
// Sits as an overlay PanelWindow anchored top+left so
// marginLeft / marginTop can position it anywhere on screen.
PanelWindow {
    id: root

    property var menuHandle: null

    function open(handle, gx, gy) {
        menuHandle = handle
        margins.left = gx
        margins.top  = gy
        visible      = true
    }

    function close() {
        visible    = false
        menuHandle = null
    }

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace:     "tray-menu"

    anchors { top: true; left: true }

    color:         "transparent"
    visible:       false
    implicitWidth: popup.implicitWidth
    implicitHeight: popup.implicitHeight

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    // Click outside to dismiss
    MouseArea {
        anchors.fill: parent
        onClicked:    root.close()
    }

    Rectangle {
        id: popup

        color:        "#111111"
        border.color: "#252525"
        border.width: 1
        radius:       4

        implicitWidth:  Math.max(180, col.implicitWidth + 16)
        implicitHeight: col.implicitHeight + 8

        MouseArea { anchors.fill: parent; onClicked: {} } // absorb

        Column {
            id: col
            anchors {
                top:         parent.top
                left:        parent.left
                right:       parent.right
                topMargin:   4
                leftMargin:  8
                rightMargin: 8
            }
            spacing: 0

            Repeater {
                model: opener.children

                delegate: Item {
                    required property QsMenuEntry modelData
                    width: col.width
                    implicitHeight: modelData.isSeparator ? 9 : 28

                    Rectangle {
                        visible: modelData.isSeparator
                        anchors.centerIn: parent
                        width:  parent.width
                        height: 1
                        color:  "#252525"
                    }

                    Rectangle {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        color:  itemHover.containsMouse && modelData.enabled
                                ? "#1a1a1a" : "transparent"
                        radius: 3

                        Text {
                            anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                            text:           modelData.text
                            font.family:    "GeistMono Nerd Font"
                            font.pixelSize: 12
                            color:          modelData.enabled ? "#e0e0e0" : "#484848"
                        }

                        Text {
                            visible: modelData.hasChildren
                            anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                            text:           "›"
                            font.pixelSize: 13
                            color:          "#606060"
                        }
                    }

                    MouseArea {
                        id: itemHover
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled:      !modelData.isSeparator && modelData.enabled
                        onClicked: { modelData.triggered(); root.close() }
                    }
                }
            }
        }
    }
}
