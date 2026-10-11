import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

// Menu-bar popover: drops under a bar icon, right-aligned to it, dismissed by a
// click outside or Escape. Solid raised layer, one hairline, 6px corners.
//   PopoverPanel { name: "network"; target: root; title: "wi-fi"; checked: ...; onToggled: ... }
PopupWindow {
    id: panel

    required property Item target
    required property string name
    property string title: ""
    property bool showSwitch: true
    property bool checked: false
    signal toggled(bool value)
    signal opened()

    default property alias content: body.data

    readonly property int panelWidth: 340

    visible: PanelState.current === name && PanelState.screenName === (target.QsWindow.window && target.QsWindow.window.screen ? target.QsWindow.window.screen.name : "")
    color: "transparent"
    grabFocus: PanelState.grab
    anchor.item: target
    anchor.rect.x: target.width - width + 8
    anchor.rect.y: target.height + 2
    implicitWidth: panelWidth
    implicitHeight: box.implicitHeight

    onVisibleChanged: {
        if (visible)
            opened()
        else if (PanelState.current === name)
            PanelState.close()
    }

    Rectangle {
        id: box
        anchors.fill: parent
        implicitHeight: col.implicitHeight + 16
        color: Theme.raised
        border.width: 1
        border.color: Theme.borderRaised
        radius: Theme.radiusLg

        focus: panel.visible
        Keys.onEscapePressed: PanelState.close()

        ColumnLayout {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
            spacing: 4

            // header: title + switch
            RowLayout {
                visible: panel.title !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                Layout.leftMargin: 6
                Layout.rightMargin: 4

                Text {
                    Layout.fillWidth: true
                    text: panel.title
                    font.family: Theme.font
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: Theme.textHi
                }

                Item {
                    visible: panel.showSwitch
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 18

                    Rectangle {
                        anchors.fill: parent
                        radius: 9
                        color: panel.checked ? Theme.pink : Theme.empty
                        border.width: 1
                        border.color: panel.checked ? Theme.pink : Theme.muted
                        Behavior on color { ColorAnimation { duration: Theme.dur } }

                        Rectangle {
                            width: 12; height: 12; radius: 6
                            anchors.verticalCenter: parent.verticalCenter
                            x: panel.checked ? parent.width - width - 3 : 3
                            color: panel.checked ? Theme.base : Theme.textDim
                            Behavior on x { NumberAnimation { duration: Theme.dur; easing.type: Easing.OutQuint } }
                            Behavior on color { ColorAnimation { duration: Theme.dur } }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: panel.toggled(!panel.checked)
                    }
                }
            }

            Rectangle {
                visible: panel.title !== ""
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.border
            }

            ColumnLayout {
                id: body
                Layout.fillWidth: true
                spacing: 2
            }
        }
    }
}
