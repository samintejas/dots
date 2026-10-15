import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import "../theme"

// Quick chat: ask Claude something without opening a session. Same shell as
// the launcher. Enter sends, Esc closes, Ctrl+L starts over, Ctrl+Y copies the
// last answer, Ctrl+M cycles the model.
//
// Backend: `claude -p` (uses your Claude login, no API key). If
// ~/.config/anthropic/key exists, it talks to the Messages API directly with
// curl instead, which answers noticeably faster.
PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    // only the focused monitor shows it
    readonly property bool active: QuickChatState.visible && Hyprland.focusedMonitor === Hyprland.monitorFor(modelData)

    readonly property string home: Quickshell.env("HOME")
    readonly property string stateDir: home + "/.local/state/quickshell/quickchat"
    readonly property string keyPath: home + "/.config/anthropic/key"

    readonly property var models: [
        { label: "haiku",  cli: "haiku",  api: "claude-haiku-5-5" },
        { label: "sonnet", cli: "sonnet", api: "claude-sonnet-5-5" },
        { label: "opus",   cli: "opus",   api: "claude-opus-5-5" }
    ]
    property int modelIndex: 0
    readonly property var model: models[modelIndex]

    readonly property string systemPrompt:
        "You are a quick-answer assistant in a desktop launcher. Answer directly in a few lines, " +
        "no preamble, no sign-off. Use markdown only when it helps (code blocks, short lists). " +
        "You have no tools and cannot browse; if you are unsure, say so."

    property var messages: []            // [{ role: "user" | "assistant", text }]
    property bool busy: false
    property string error: ""
    property string sessionId: ""        // claude -p: one session per chat
    property bool started: false         // first turn sent (next ones resume)
    property bool useApi: false          // decided when a question is sent
    property string keyText: ""

    function uuid() {
        const h = "0123456789abcdef";
        let s = "";
        for (let i = 0; i < 36; i++) {
            if (i === 8 || i === 13 || i === 18 || i === 23) s += "-";
            else if (i === 14) s += "4";
            else if (i === 19) s += h[8 + Math.floor(Math.random() * 4)];
            else s += h[Math.floor(Math.random() * 16)];
        }
        return s;
    }

    function reset() {
        proc.running = false;
        messages = [];
        busy = false;
        error = "";
        sessionId = uuid();
        started = false;
    }

    function setLast(text) {
        const m = messages.slice();
        m[m.length - 1] = { role: "assistant", text: text };
        messages = m;
    }

    function lastAnswer() {
        for (let i = messages.length - 1; i >= 0; i--)
            if (messages[i].role === "assistant") return messages[i].text;
        return "";
    }

    function send() {
        const q = input.text.trim();
        if (q === "" || busy) return;
        input.text = "";
        error = "";
        useApi = keyText.trim() !== "";
        messages = messages.concat([{ role: "user", text: q }, { role: "assistant", text: "" }]);
        busy = true;

        if (useApi) {
            const turns = messages.slice(0, -1).map(m => ({ role: m.role, content: m.text }));
            const body = JSON.stringify({
                model: model.api, max_tokens: 2048, stream: true,
                system: systemPrompt, messages: turns
            });
            proc.command = ["curl", "-sN", "https://api.anthropic.com/v1/messages",
                "-H", "x-api-key: " + keyText.trim(),
                "-H", "anthropic-version: 2023-06-01",
                "-H", "content-type: application/json",
                "-d", body];
        } else {
            const cmd = ["claude", "-p", q, "--model", model.cli, "--tools", "",
                "--disable-slash-commands", "--strict-mcp-config", "--setting-sources", "",
                "--system-prompt", systemPrompt,
                "--output-format", "stream-json", "--include-partial-messages", "--verbose"];
            cmd.push(started ? "--resume" : "--session-id", sessionId);
            proc.command = cmd;
            started = true;
        }
        proc.running = true;
    }

    function onLine(line) {
        if (line === "") return;
        let j;
        try { j = JSON.parse(line); } catch (e) { return; }
        const last = messages[messages.length - 1];
        if (!last || last.role !== "assistant") return;

        if (useApi) {
            // Messages API server-sent events
            if (j.type === "content_block_delta" && j.delta && j.delta.type === "text_delta")
                setLast(last.text + j.delta.text);
            else if (j.type === "error")
                error = "error: " + (j.error ? j.error.message : "request failed");
            return;
        }
        if (j.type === "stream_event" && j.event && j.event.type === "content_block_delta"
            && j.event.delta && j.event.delta.type === "text_delta") {
            setLast(last.text + j.event.delta.text);
        } else if (j.type === "result") {
            if (j.is_error) error = "error: " + (j.result || "request failed");
            else if (last.text === "" && j.result) setLast(j.result);
        }
    }

    Process {
        id: mkdir
        command: ["mkdir", "-p", root.stateDir]
    }

    FileView {
        id: keyFile
        path: root.keyPath
        onLoaded: root.keyText = text()
    }

    Process {
        id: proc
        workingDirectory: root.stateDir
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                // API stream lines look like `data: {...}`; the CLI prints bare JSON
                root.onLine(data.indexOf("data: ") === 0 ? data.substring(6) : data);
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim() !== "" && root.error === "" && root.lastAnswer() === "")
                root.error = "error: " + text.trim().split("\n")[0]
        }
        onExited: (code, status) => {
            root.busy = false;
            if (code !== 0 && root.error === "" && root.lastAnswer() === "")
                root.error = "error: could not reach claude (exit " + code + ")";
        }
    }

    Process {
        id: copier
    }

    Component.onCompleted: {
        mkdir.running = true;
        sessionId = uuid();
    }

    function takePending() {
        if (!active || QuickChatState.pending === "") return;
        const q = QuickChatState.pending;
        QuickChatState.pending = "";
        input.text = q;
        send();
    }

    onActiveChanged: {
        if (active) {
            keyFile.reload();
            input.forceActiveFocus();
            takePending();
        }
    }

    Connections {
        target: QuickChatState
        function onPendingChanged() { root.takePending() }
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.namespace: "quickchat"
    WlrLayershell.keyboardFocus: active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    visible: active

    // scrim: click outside to close
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim

        MouseArea {
            anchors.fill: parent
            onClicked: QuickChatState.visible = false
        }
    }

    Rectangle {
        id: panel

        width: 680
        readonly property int maxBody: Math.round(root.height * 0.55)
        height: inputWell.height + body.height + footer.height + 8 + (body.visible ? 8 : 0) + 8 + 1
        anchors.horizontalCenter: parent.horizontalCenter
        // centred as if the answer area were full, so the prompt stays put while answers stream in
        y: Math.round((parent.height - (inputWell.height + maxBody + footer.height + 8 + 8 + 8 + 1)) / 2)
        radius: Theme.radiusLg
        color: Theme.overlay
        border.width: 1
        border.color: Theme.borderOverlay

        MouseArea { anchors.fill: parent }   // absorb

        // composite field: the focus mark moves to the container
        Rectangle {
            id: inputWell
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 8 }
            height: 40
            radius: Theme.radiusSm
            color: Theme.well
            border.width: input.activeFocus ? 2 : 1
            border.color: input.activeFocus ? Theme.focusRing : Theme.borderControl

            Text {
                id: mark
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                text: root.busy ? "…" : ">"
                font.family: Theme.font
                font.pixelSize: 13
                color: Theme.pink
            }

            TextInput {
                id: input
                anchors { left: mark.right; right: modelLabel.left; verticalCenter: parent.verticalCenter; leftMargin: 10; rightMargin: 8 }
                font.family: Theme.font
                font.pixelSize: 13
                color: Theme.textHi
                selectionColor: Theme.selection
                selectedTextColor: Theme.textMax
                clip: true
                focus: true

                Keys.onEscapePressed: QuickChatState.visible = false
                Keys.onReturnPressed: root.send()
                Keys.onEnterPressed: root.send()
                Keys.onPressed: event => {
                    if (event.modifiers & Qt.ControlModifier) {
                        if (event.key === Qt.Key_L) {
                            root.reset();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Y) {
                            const t = root.lastAnswer();
                            if (t !== "") {
                                copier.command = ["wl-copy", t];
                                copier.running = true;
                            }
                            event.accepted = true;
                        } else if (event.key === Qt.Key_M) {
                            root.modelIndex = (root.modelIndex + 1) % root.models.length;
                            event.accepted = true;
                        }
                    }
                }

                Text {
                    visible: input.text === "" && !input.preeditText
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.messages.length === 0 ? "ask claude" : "follow up"
                    font: input.font
                    color: Theme.subtle
                }
            }

            Text {
                id: modelLabel
                anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: 12 }
                text: root.model.label + (root.keyText.trim() !== "" ? " · api" : "")
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }
        }

        // conversation: newest at the bottom, stays pinned there while streaming
        Flickable {
            id: body
            visible: root.messages.length > 0 || root.error !== ""
            anchors { top: inputWell.bottom; left: parent.left; right: parent.right; topMargin: 8; leftMargin: 8; rightMargin: 8 }
            height: visible ? Math.min(col.implicitHeight + 8, panel.maxBody) : 0
            contentHeight: col.implicitHeight + 8
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            onContentHeightChanged: contentY = Math.max(0, contentHeight - height)

            Column {
                id: col
                width: body.width
                spacing: 10

                Repeater {
                    model: root.messages

                    delegate: Item {
                        id: msg
                        required property var modelData
                        width: col.width
                        implicitHeight: bubble.implicitHeight

                        // question: a quiet line; answer: full ink, markdown
                        Text {
                            id: bubble
                            width: parent.width
                            visible: msg.modelData.role === "user" || msg.modelData.text !== ""
                            text: msg.modelData.text
                            textFormat: msg.modelData.role === "assistant" ? Text.MarkdownText : Text.PlainText
                            wrapMode: Text.Wrap
                            // the answer is prose, so it sets in the sans; the question stays mono
                            font.family: msg.modelData.role === "user" ? Theme.font : Theme.fontSans
                            font.pixelSize: msg.modelData.role === "user" ? 12 : 14
                            lineHeight: msg.modelData.role === "user" ? 1 : 1.2
                            color: msg.modelData.role === "user" ? Theme.subtle : Theme.textHi
                            linkColor: Theme.blue
                            onLinkActivated: link => Qt.openUrlExternally(link)
                        }
                    }
                }

                Text {
                    visible: root.error !== ""
                    width: col.width
                    text: root.error
                    wrapMode: Text.Wrap
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Theme.red
                }
            }
        }

        // status line: key hints
        Item {
            id: footer
            anchors { top: body.bottom; left: parent.left; right: parent.right; topMargin: body.visible ? 8 : 8 }
            height: 28

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Theme.border
            }

            Text {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 12 }
                text: "↵ ask   ^y copy   ^l new   ^m model   esc close"
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
            }
        }
    }
}
