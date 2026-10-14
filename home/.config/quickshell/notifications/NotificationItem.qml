import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../theme"

// Dots Toast: a card with a 3px severity bar, a severity glyph whose shape
// differs per state (never colour alone), a medium title, a timestamp and a
// dismiss button. Popups are floating (raised + stronger border); in the
// drawer the same card rests on the sheet (surface + default border).
Item {
    id: root

    property var notification: null
    property bool isPopup: false
    readonly property bool hovered: cardHover.hovered

    // timestamp is taken when the card is first shown
    readonly property date created: new Date()

    signal closed()
    signal actionInvoked(string identifier)
    signal activated()

    // 0 info, 1 success, 2 warning, 3 danger, 4 low
    readonly property int severity: {
        if (!notification) return 0
        if (notification.urgency === NotificationUrgency.Critical) return 3
        var s = (notification.summary + " " + notification.body).toLowerCase()
        if (s.match(/disconnect|unpair|removed|lost|failed|unavailable|offline/)) return 2
        if (s.match(/connect|paired|available|online|enabled/)) return 1
        if (notification.urgency === NotificationUrgency.Low) return 4
        return 0
    }

    readonly property var severityColors: [Theme.blue, Theme.green, Theme.peach, Theme.red, Theme.occupied]
    // circle / circle-check / triangle / octagon / bell
    readonly property var severityGlyphs: ["󰋽", "󰗡", "󰀦", "󰀩", "󰂚"]
    readonly property color barColor: severityColors[severity]
    readonly property color glyphColor: severity === 4 ? Theme.subtle : barColor

    readonly property string iconSource: {
        if (!notification) return ""
        // a URL image (album art) comes back from Quickshell wrapped as a
        // theme icon lookup, which cannot load it: unwrap it to the URL itself
        var img = notification.image || ""
        var wrapped = img.match(/^image:\/\/icon\/((?:https?|file):.*)$/)
        if (wrapped) return wrapped[1]
        if (img !== "") return img
        var ai = notification.appIcon || ""
        if (ai === "") return ""
        if (ai.startsWith("file://") || ai.startsWith("http://") || ai.startsWith("https://") || ai.startsWith("qrc:") || ai.startsWith("image://")) return ai
        if (ai.startsWith("/")) return "file://" + ai
        return Quickshell.iconPath(ai, "dialog-information")
    }
    readonly property bool hasImage: iconSource !== ""
    readonly property var actionList: {
        if (!notification) return []
        var out = []
        for (var i = 0; i < notification.actions.length && out.length < 2; i++) {
            if (notification.actions[i].identifier !== "default") out.push(notification.actions[i])
        }
        return out
    }
    readonly property bool hasActions: actionList.length > 0

    implicitWidth:  parent ? parent.width : 360
    implicitHeight: card.implicitHeight

    Rectangle {
        id: card
        anchors { left: parent.left; right: parent.right }
        implicitHeight: content.implicitHeight + 20 + (root.hasActions ? 32 : 0)
        radius: root.isPopup ? Theme.radiusLg : Theme.radiusMd
        color: root.isPopup
            ? (cardHover.hovered ? Qt.lighter(Theme.raised, 1.15) : Theme.raised)
            : (cardHover.hovered ? Theme.hover : Theme.surface)
        border.width: 0

        Behavior on color { ColorAnimation { duration: Theme.dur } }
        Behavior on border.color { ColorAnimation { duration: Theme.dur } }

        HoverHandler { id: cardHover }

        // click the card body: run its default action (popup also dismisses)
        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: root.activated()
        }

        // severity bar: full height, flush left, clipped to the card's rounded shape
        Item {
            anchors.fill: parent
            z: 1
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: barMask
            }

            Rectangle {
                width: 3
                color: root.barColor
                anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
            }
        }

        Rectangle {
            id: barMask
            anchors.fill: parent
            radius: card.radius
            visible: false
            layer.enabled: true
        }

        RowLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 10; leftMargin: 14 }
            spacing: 10

            Rectangle {
                visible: root.hasImage
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                Layout.alignment: Qt.AlignTop
                radius: Theme.radiusMd
                color: Theme.hover
                clip: true

                Image {
                    anchors.fill: parent
                    source: root.iconSource
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    asynchronous: true
                    sourceSize.width: width * 2
                    sourceSize.height: height * 2
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    width: parent.width
                    spacing: 6

                    Text {
                        text: root.severityGlyphs[root.severity]
                        font.family: Theme.font
                        font.pixelSize: 14
                        color: root.glyphColor
                    }

                    Text {
                        Layout.fillWidth: true
                        text: notification ? notification.summary : ""
                        font.family: Theme.font
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: Theme.textHi
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Text {
                        text: Qt.formatDateTime(root.created, "hh:mm")
                        font.family: Theme.font
                        font.pixelSize: 11
                        color: Theme.subtle
                    }

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Rectangle {
                            anchors.fill: parent
                            radius: Theme.radiusSm
                            color: closeArea.containsMouse ? Theme.hover : "transparent"
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            font.family: Theme.font
                            font.pixelSize: 11
                            color: closeArea.containsMouse ? Theme.textHi : Theme.subtle
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.closed()
                        }
                    }
                }

                Text {
                    visible: text !== ""
                    text: notification ? notification.body : ""
                    width: parent.width
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Theme.textHi
                    wrapMode: Text.WordWrap
                    maximumLineCount: root.isPopup ? 3 : 6
                    elide: Text.ElideRight
                    lineHeight: 1.4
                }

                Text {
                    visible: notification && notification.appName !== ""
                    text: notification ? notification.appName.toLowerCase() : ""
                    font.family: Theme.font
                    font.pixelSize: 11
                    color: Theme.subtle
                }
            }
        }

        // actions: secondary buttons, lowercase verbs
        Row {
            visible: root.hasActions
            spacing: 6
            anchors { right: parent.right; bottom: parent.bottom; rightMargin: 10; bottomMargin: 8 }

            Repeater {
                model: root.actionList

                delegate: Rectangle {
                    id: btn
                    required property var modelData
                    height: 24
                    width: btnLabel.implicitWidth + 20
                    radius: Theme.radiusSm
                    color: btnArea.containsMouse ? Theme.hover : "transparent"
                    border.width: 1
                    border.color: Theme.borderRaised

                    Text {
                        id: btnLabel
                        anchors.centerIn: parent
                        text: btn.modelData.text.toLowerCase()
                        font.family: Theme.font
                        font.pixelSize: 11
                        color: Theme.textHi
                    }

                    MouseArea {
                        id: btnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.actionInvoked(btn.modelData.identifier)
                    }
                }
            }
        }
    }
}
