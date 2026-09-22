import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Item {
    id: root

    required property var screen
    readonly property string screenName: screen.name
    // Match waybar persistent-workspaces
    readonly property bool isFirstScreen: screenName === "eDP-1"
    readonly property var wsIds: isFirstScreen ? [1, 2, 3, 4, 5] : [6, 7, 8, 9, 10]
    readonly property color activePillColor: isFirstScreen ? "#ef9cd8" : "#89b4fa"
    readonly property var hyprMonitor: Hyprland.monitorFor(screen)
    readonly property int activeWsId: hyprMonitor && hyprMonitor.activeWorkspace ? hyprMonitor.activeWorkspace.id : -1

    function getWorkspace(wsId) {
        for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
            if (Hyprland.workspaces.values[i].id === wsId)
                return Hyprland.workspaces.values[i];

        }
        return null;
    }

    implicitWidth: row.implicitWidth + 4
    implicitHeight: parent.height

    RowLayout {
        id: row

        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: root.wsIds

            delegate: Item {
                required property int modelData
                readonly property int wsId: modelData
                readonly property bool isActive: wsId === root.activeWsId
                readonly property bool isEmpty: {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        const ws = Hyprland.workspaces.values[i];
                        if (ws.id === wsId)
                            return ws.toplevels.values.length === 0;

                    }
                    return true;
                }
                readonly property bool isUrgent: {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        const ws = Hyprland.workspaces.values[i];
                        if (ws.id === wsId)
                            return ws.urgent;

                    }
                    return false;
                }

                implicitWidth: 24
                implicitHeight: 26

                MouseArea {
                    id: wsArea

                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton
                    hoverEnabled: true
                    preventStealing: true
                    onClicked: Hyprland.dispatch("workspace " + wsId)

                    Rectangle {
                        anchors.centerIn: parent
                        width: isActive ? 18 : (isEmpty ? 6 : 8)
                        height: isActive ? 6 : (isEmpty ? 6 : 8)
                        radius: isActive ? 3 : (isEmpty ? 1.5 : 4)
                        color: {
                            if (isUrgent)
                                return "#f38ba8";

                            if (isActive)
                                return root.activePillColor;

                            if (wsArea.containsMouse)
                                return "#555555";

                            if (isEmpty)
                                return "#222222";

                            return "#3a3a3a";
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuint
                            }

                        }

                        Behavior on height {
                            NumberAnimation {
                                duration: 150
                                easing.type: Easing.OutQuint
                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                }

            }

        }

    }

}
