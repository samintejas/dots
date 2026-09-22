import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// Reusable notification card — used in both popup and drawer.
Item {
    id: root

    property var notification: null
    property bool isPopup: false

    signal closed()
    signal actionInvoked(string identifier)

    readonly property color bgColor:     "#111111"
    readonly property color borderColor: "#252525"
    readonly property color textColor:   "#e0e0e0"
    readonly property color mutedColor:  "#686868"
    readonly property color ghostColor:  "#484848"
    readonly property color accentColor: "#89b4fa"
    readonly property color urgentColor: "#f38ba8"
    readonly property color successColor: "#a6e3a1"
    readonly property color warnColor:   "#f9e2af"
    readonly property color hoverColor:  "#1a1a1a"

    readonly property int semanticKind: {
        if (!notification) return 0
        var s = (notification.summary + " " + notification.body).toLowerCase()
        if (s.match(/disconnect|unpair|removed|lost|failed|unavailable|offline/)) return 2
        if (s.match(/connect|paired|available|online|enabled/)) return 1
        return 0
    }

    readonly property color leftBorder: {
        if (!notification) return borderColor
        if (notification.urgency === NotificationUrgency.Critical) return urgentColor
        if (semanticKind === 1) return successColor
        if (semanticKind === 2) return warnColor
        if (notification.urgency === NotificationUrgency.Low)      return ghostColor
        return accentColor
    }

    readonly property string iconSource: {
        if (!notification) return ""
        if (notification.image && notification.image !== "") return notification.image
        var ai = notification.appIcon || ""
        if (ai === "") return ""
        if (ai.startsWith("file://") || ai.startsWith("http://") || ai.startsWith("https://") || ai.startsWith("qrc:") || ai.startsWith("image://")) return ai
        if (ai.startsWith("/")) return "file://" + ai
        return Quickshell.iconPath(ai, "dialog-information")
    }
    readonly property bool hasImage: iconSource !== ""
    readonly property bool hasActions: notification && notification.actions.length > 0

    implicitWidth:  parent ? parent.width : 360
    implicitHeight: card.implicitHeight

    Rectangle {
        id: card
        anchors { left: parent.left; right: parent.right }
        implicitHeight: mainCol.implicitHeight + (hasActions ? 31 : 0)
        color: bgColor
        radius: 4
        border.color: borderColor
        border.width: 1

        // urgency accent stripe
        Rectangle {
            width: 2
            anchors {
                top: parent.top; bottom: parent.bottom; left: parent.left
                topMargin: 1; bottomMargin: 1; leftMargin: 1
            }
            color: root.leftBorder
            radius: 2
        }

        // main content row
        RowLayout {
            id: mainCol
            anchors { left: parent.left; right: parent.right; top: parent.top }
            spacing: 0

            // notification image
            Item {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                Layout.leftMargin: 12
                Layout.topMargin: 10
                Layout.bottomMargin: 10
                visible: root.hasImage

                Rectangle {
                    anchors.fill: parent
                    radius: 4
                    color: "#1a1a1a"
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.iconSource
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        sourceSize.width:  width  * 2
                        sourceSize.height: height * 2
                    }
                }
            }

            // spacer when no image
            Item {
                Layout.preferredWidth: root.hasImage ? 0 : 2
                visible: !root.hasImage
            }

            // text content
            Column {
                Layout.fillWidth: true
                Layout.margins: 10
                Layout.leftMargin: root.hasImage ? 10 : 12
                spacing: 2

                // app name + close button row
                RowLayout {
                    width: parent.width
                    spacing: 0

                    Text {
                        text: notification ? notification.appName.toUpperCase() : ""
                        font.family: "GeistMono Nerd Font"
                        font.pixelSize: 10
                        font.letterSpacing: 0.5
                        color: root.ghostColor
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Item {
                        Layout.preferredWidth: 18
                        Layout.preferredHeight: 18

                        Rectangle {
                            anchors.fill: parent
                            color: closeHover.containsMouse ? Qt.rgba(0.85, 0.44, 0.44, 0.15) : "transparent"
                            radius: 3

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                font.family: "GeistMono Nerd Font"
                                font.pixelSize: 10
                                color: closeHover.containsMouse ? root.urgentColor : root.ghostColor
                            }
                        }

                        MouseArea {
                            id: closeHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.closed()
                        }
                    }
                }

                // summary
                Text {
                    text: notification ? notification.summary : ""
                    font.family: "GeistMono Nerd Font"
                    font.pixelSize: 12
                    font.bold: true
                    color: root.textColor
                    width: parent.width
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // body
                Text {
                    text: notification ? notification.body : ""
                    font.family: "GeistMono Nerd Font"
                    font.pixelSize: 11
                    color: root.mutedColor
                    width: parent.width
                    wrapMode: Text.WordWrap
                    maximumLineCount: root.isPopup ? 3 : 6
                    elide: Text.ElideRight
                    lineHeight: 1.4
                    visible: text !== ""
                }
            }
        }

        // separator above actions
        Rectangle {
            anchors {
                left: parent.left; right: parent.right
                top: mainCol.bottom
            }
            height: 1
            color: root.borderColor
            visible: root.hasActions
        }

        // action buttons
        Row {
            id: actionRow
            anchors {
                left: parent.left; right: parent.right
                top: mainCol.bottom; topMargin: 1
            }
            visible: root.hasActions
            height: root.hasActions ? 30 : 0

            Repeater {
                model: notification ? notification.actions : []

                delegate: Item {
                    required property var modelData
                    required property int index
                    width: actionRow.width / (notification ? notification.actions.length : 1)
                    height: 30

                    Rectangle {
                        anchors.fill: parent
                        color: actionHover.containsMouse ? root.hoverColor : "transparent"

                        // bottom-left radius on first, bottom-right on last
                        radius: 0
                        Rectangle {
                            anchors.fill: parent
                            color: parent.color
                            radius: 4
                            visible: index === 0 || index === notification.actions.length - 1
                        }

                        // left separator
                        Rectangle {
                            visible: index > 0
                            width: 1; height: parent.height
                            anchors.left: parent.left
                            color: root.borderColor
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.text
                            font.family: "GeistMono Nerd Font"
                            font.pixelSize: 11
                            color: actionHover.containsMouse ? root.textColor : root.mutedColor
                        }
                    }

                    MouseArea {
                        id: actionHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.actionInvoked(modelData.identifier)
                    }
                }
            }
        }
    }
}
