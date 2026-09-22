import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.exclusiveZone: 0
    WlrLayershell.namespace:     "wallpaper-drawer"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors { top: true; bottom: true; right: true }

    color:          "transparent"
    visible:        WallpaperState.visible
    implicitWidth:  overlay.width

    Item {
        id: overlay
        width: root.screen ? root.screen.width : 1920
        height: root.screen ? root.screen.height : 1080

        readonly property int drawerW: 380

        // dimmed backdrop
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
            opacity: drawer.x < overlay.drawerW ? 1 - (drawer.x / overlay.drawerW) : 0

            MouseArea {
                anchors.fill: parent
                onClicked: WallpaperState.visible = false
            }
        }

        Rectangle {
            id: drawer
            width: overlay.drawerW
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }

            color: "#0a0a0a"
            border.width: 0

            x: WallpaperState.visible ? 0 : overlay.drawerW
            Behavior on x {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // left border matching hyprland active border
            Rectangle {
                id: leftBorder
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
                width: 2
                color: "#505050"
                z: 1
            }

            // header
            Rectangle {
                id: header
                anchors { top: parent.top; left: leftBorder.right; right: parent.right }
                height: 44
                color: "#111111"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#252525"
                }

                Text {
                    anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 14 }
                    text: "WALLPAPERS"
                    font.family: "GeistMono Nerd Font"
                    font.pixelSize: 10
                    font.letterSpacing: 0.5
                    color: "#484848"
                }

                Text {
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 14 }
                    text: WallpaperState.results.length > 0 ? WallpaperState.results.length : ""
                    font.family: "GeistMono Nerd Font"
                    font.pixelSize: 11
                    color: "#484848"
                }
            }

            // search bar
            Rectangle {
                id: searchBar
                anchors { top: header.bottom; left: leftBorder.right; right: parent.right }
                height: 44
                color: "#0a0a0a"

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "#252525"
                }

                RowLayout {
                    anchors { fill: parent; leftMargin: 14; rightMargin: 14 }
                    spacing: 10

                    Text {
                        text: "󰍉"
                        font.family: "GeistMono Nerd Font"
                        font.pixelSize: 14
                        color: "#484848"
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        font.family: "GeistMono Nerd Font"
                        font.pixelSize: 12
                        color: "#cdd6f4"
                        selectionColor: "#ef9cd8"
                        selectedTextColor: "#0a0a0a"
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        focus: WallpaperState.visible
                        activeFocusOnTab: true

                        Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            text: "search wallhaven"
                            font: parent.font
                            color: "#484848"
                            visible: parent.text === "" && !parent.activeFocus
                        }

                        Timer {
                            id: debounce
                            interval: 450
                            onTriggered: WallpaperState.search(searchInput.text)
                        }
                        onTextChanged: debounce.restart()
                        Keys.onReturnPressed: { debounce.stop(); WallpaperState.search(text) }
                        Keys.onEscapePressed: WallpaperState.visible = false
                    }

                    Text {
                        text: WallpaperState.fetching ? "…" : ""
                        font.family: "GeistMono Nerd Font"
                        font.pixelSize: 12
                        color: "#585b70"
                    }
                }
            }

            // thumbnail list
            ListView {
                id: listView
                anchors {
                    top: searchBar.bottom
                    left: leftBorder.right
                    right: parent.right
                    bottom: parent.bottom
                    leftMargin: 10
                    rightMargin: 10
                    topMargin: 10
                    bottomMargin: 10
                }
                clip: true
                model: WallpaperState.results
                spacing: 8
                cacheBuffer: 600
                boundsBehavior: Flickable.StopAtBounds

                // scroll position is reset when results is reassigned during
                // pagination — save before loadMore, restore after results update
                property real savedY: -1

                Connections {
                    target: WallpaperState
                    function onResultsChanged() {
                        if (listView.savedY < 0) return
                        var y = listView.savedY
                        listView.savedY = -1
                        Qt.callLater(function() { listView.contentY = y })
                    }
                }

                delegate: Rectangle {
                    id: tile
                    required property int index
                    required property var modelData

                    width: ListView.view.width
                    implicitHeight: width * 9 / 16
                    color: "#111111"
                    radius: 4
                    border.color: hover.containsMouse ? "#89b4fa" : "#252525"
                    border.width: 1
                    clip: true

                    Image {
                        anchors.fill: parent
                        anchors.margins: 1
                        source: tile.modelData.thumbs ? tile.modelData.thumbs.large : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        smooth: true
                    }

                    // resolution tag on hover
                    Rectangle {
                        anchors { left: parent.left; bottom: parent.bottom; margins: 6 }
                        width: resTag.implicitWidth + 10
                        height: resTag.implicitHeight + 6
                        color: Qt.rgba(0, 0, 0, 0.65)
                        radius: 3
                        visible: hover.containsMouse

                        Text {
                            id: resTag
                            anchors.centerIn: parent
                            text: tile.modelData.resolution || ""
                            font.family: "GeistMono Nerd Font"
                            font.pixelSize: 10
                            color: "#cdd6f4"
                        }
                    }

                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            WallpaperState.setWallpaper(tile.modelData.path)
                            WallpaperState.visible = false
                        }
                    }
                }

                footer: Item {
                    width: listView.width
                    height: 44
                    Text {
                        anchors.centerIn: parent
                        text: {
                            if (WallpaperState.fetching) return "loading…"
                            if (WallpaperState.results.length === 0) return "no wallpapers"
                            if (!WallpaperState.hasMore) return "— end —"
                            return ""
                        }
                        font.family: "GeistMono Nerd Font"
                        font.pixelSize: 11
                        color: "#484848"
                    }
                }

                // lazy-load next page when near bottom
                onContentYChanged: {
                    if (contentHeight <= 0) return
                    var remaining = contentHeight - (contentY + height)
                    if (remaining < 500 && WallpaperState.hasMore && !WallpaperState.fetching) {
                        savedY = contentY
                        WallpaperState.loadMore()
                    }
                }
            }
        }
    }
}
