pragma Singleton
import QtQuick

QtObject {
    property bool visible: false

    property string pending: ""    // a question handed over by `ask`, sent as soon as the panel is up

    function toggle() { visible = !visible }

    function ask(q) {
        pending = q
        visible = true
    }
}
