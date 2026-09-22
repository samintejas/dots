pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // drawer state
    property bool visible: false
    property string query: ""
    property var results: []
    property int currentPage: 0
    property int lastPage: 1
    property bool fetching: false
    property bool hasMore: false

    // current wallpaper (URL — Wallhaven full-size path)
    property string currentUrl: ""

    // load persisted wallpaper URL on startup
    property Process _loader: Process {
        running: true
        command: ["sh", "-c", "cat \"$HOME/.cache/quickshell/wallpaper_url\" 2>/dev/null"]
        stdout: StdioCollector {
            onStreamFinished: {
                var content = text.trim()
                if (content.length > 0) root.currentUrl = content
            }
        }
    }

    function toggle() {
        visible = !visible
        if (visible && results.length === 0) fetchPage(1)
    }

    function search(q) {
        query = q
        results = []
        currentPage = 0
        hasMore = false
        fetchPage(1)
    }

    function loadMore() {
        if (!hasMore || fetching) return
        fetchPage(currentPage + 1)
    }

    function fetchPage(pageNum) {
        if (fetching) return
        fetching = true

        var params = [
            "atleast=1920x1080",
            "ratios=16x9",
            "sorting=" + (query === "" ? "toplist" : "relevance"),
            "page=" + pageNum
        ]
        if (query !== "") params.push("q=" + encodeURIComponent(query))
        var url = "https://wallhaven.cc/api/v1/search?" + params.join("&")

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return
            fetching = false
            if (xhr.status !== 200) {
                console.warn("wallhaven:", xhr.status, xhr.statusText)
                return
            }
            try {
                var json = JSON.parse(xhr.responseText)
                var data = json.data || []
                if (pageNum === 1) {
                    results = data
                } else {
                    var copy = results.slice()
                    for (var i = 0; i < data.length; i++) copy.push(data[i])
                    results = copy
                }
                currentPage = pageNum
                if (json.meta) {
                    lastPage = json.meta.last_page || 1
                    hasMore = currentPage < lastPage
                }
            } catch (e) {
                console.warn("wallhaven parse error:", e)
            }
        }
        xhr.send()
    }

    function setWallpaper(url) {
        currentUrl = url
        // persist — URL is passed as $1 so no shell-escaping needed
        Quickshell.execDetached([
            "sh", "-c",
            "mkdir -p \"$HOME/.cache/quickshell\" && printf '%s' \"$1\" > \"$HOME/.cache/quickshell/wallpaper_url\"",
            "sh",
            url
        ])
    }
}
