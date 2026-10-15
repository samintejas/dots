import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

// Custom styled tray context menu: a popup anchored under the tray icon.
// The compositor's focus grab dismisses it on a click anywhere else, like
// the bar popovers.
PopupWindow {
    id: root

    property var menuHandle: null
    property Item anchorItem: null
    property var lastHandle: null
    property double closedAt: 0    // ms; swallows the right-click that dismissed it

    function open(handle, item) {
        // that right-click already closed this menu through the grab; don't reopen it
        if (handle === lastHandle && Date.now() - closedAt < 200)
            return
        menuHandle = handle
        anchorItem = item
        visible    = true
    }

    function close() {
        visible = false
    }

    onVisibleChanged: {
        if (!visible) {
            lastHandle = menuHandle
            closedAt   = Date.now()
            menuHandle = null
        }
    }

    anchor.item:   anchorItem
    // the icon is centred in the 32px bar: drop to the bar's bottom edge, plus a 2px gap
    anchor.rect.y: anchorItem ? anchorItem.height + 10 : 0
    grabFocus:     true

    color:         "transparent"
    visible:       false
    implicitWidth: popup.implicitWidth
    implicitHeight: popup.implicitHeight

    QsMenuOpener {
        id: opener
        menu: root.menuHandle
    }

    Rectangle {
        id: popup

        color:        Theme.raised
        border.color: Theme.borderRaised
        border.width: 1
        radius:       Theme.radiusLg

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
                        color:  Theme.border
                    }

                    Rectangle {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        color:  itemHover.containsMouse && modelData.enabled
                                ? Theme.hover : "transparent"
                        radius: Theme.radiusMd

                        Text {
                            anchors { left: parent.left; leftMargin: 4; verticalCenter: parent.verticalCenter }
                            text:           modelData.text
                            font.family:    Theme.font
                            font.pixelSize: 12
                            color:          modelData.enabled ? Theme.textHi : Theme.subtle
                        }

                        Text {
                            visible: modelData.hasChildren
                            anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                            text:           "›"
                            font.pixelSize: 13
                            color:          Theme.muted
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
