import QtQuick
import QtQuick.Layouts
import "../theme"

// One row in a popover list: glyph, title (+ optional subtitle), trailing text.
// While hovered, `hoverText` (e.g. "disconnect") replaces the trailing text.
Rectangle {
    id: row

    property string icon: ""
    property color iconColor: Theme.subtle
    property string title: ""
    property string subtitle: ""
    property string trailing: ""
    property color trailingColor: Theme.subtle
    property string hoverText: ""
    property bool active: false      // the current item: brighter title
    property bool dimmed: false
    readonly property bool hovered: area.containsMouse

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 32
    radius: Theme.radiusMd
    color: area.containsMouse ? Theme.hover : "transparent"

    RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
        spacing: 10

        Text {
            Layout.preferredWidth: 18
            horizontalAlignment: Text.AlignHCenter
            text: row.icon
            font.family: Theme.font
            font.pixelSize: 16
            color: row.iconColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: row.title
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: 12
                font.weight: row.active ? Font.Medium : Font.Normal
                color: row.dimmed ? Theme.muted : (row.active ? Theme.textMax : Theme.textHi)
            }

            Text {
                visible: row.subtitle !== ""
                Layout.fillWidth: true
                text: row.subtitle
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.subtle
            }
        }

        Text {
            visible: text !== ""
            text: row.hovered && row.hoverText !== "" ? row.hoverText : row.trailing
            font.family: Theme.font
            font.pixelSize: 11
            color: row.hovered && row.hoverText !== "" ? Theme.textHi : row.trailingColor
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        onClicked: row.clicked()
    }
}
