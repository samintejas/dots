import QtQuick
import Quickshell
import "../theme"

// Hover hint for a bar item: solid raised layer, 1px border, lowercase text.
// Usage inside an Item:  Hint { target: root; text: "87% charging" }
Item {
    id: hint

    required property Item target
    property string text: ""
    property bool shown: false

    HoverHandler {
        parent: hint.target
        onHoveredChanged: hovered ? show.restart() : (show.stop(), hint.shown = false)
    }

    Timer {
        id: show
        interval: 400
        onTriggered: hint.shown = hint.text !== ""
    }

    PopupWindow {
        visible: hint.shown
        color: "transparent"
        anchor.item: hint.target
        anchor.rect.y: hint.target.height
        anchor.rect.x: (hint.target.width - width) / 2
        implicitWidth: box.implicitWidth
        implicitHeight: box.implicitHeight

        Rectangle {
            id: box
            implicitWidth: label.implicitWidth + 16
            implicitHeight: 24
            color: Theme.raised
            border.color: Theme.line
            border.width: 1
            radius: Theme.radiusLg

            Text {
                id: label
                anchors.centerIn: parent
                text: hint.text
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.textHi
            }
        }
    }
}
