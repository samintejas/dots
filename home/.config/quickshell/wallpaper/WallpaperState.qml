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

    // Remote Wallhaven URL of the current pick — persisted for reference.
    property string currentUrl: ""
    // Local file:// the Wallpaper Image actually loads. The image is cached to
    // disk so the wallpaper survives a restart with no network; previously the
    // Image pulled straight from the remote URL and came up blank offline.
    property string currentPath: ""
    property bool downloading: false

    // Restore the cached image on startup, if one was downloaded before.
    property Process _loader: Process {
        running: true
        command: ["sh", "-c", "d=\"${XDG_CACHE_HOME:-$HOME/.cache}/quickshell\"; [ -f \"$d/wallpaper.img\" ] && printf 'file://%s' \"$d/wallpaper.img\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p.length > 0)
                    root.currentPath = p + "?v=0";

            }
        }
    }

    // Downloads to a temp file and renames into place, so a half-finished or
    // failed download can never replace a working wallpaper.
    property Process _downloader: Process {
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim();
                if (p.length > 0)
                    root.currentPath = p + "?v=" + Date.now();

            }
        }
        onExited: (code) => {
            root.downloading = false;
            if (code !== 0)
                console.warn("wallpaper: download failed, keeping previous image");

        }
    }

    function toggle() {
        visible = !visible;
        if (visible && results.length === 0)
            fetchPage(1);

    }

    function search(q) {
        query = q;
        results = [];
        currentPage = 0;
        hasMore = false;
        fetchPage(1);
    }

    function loadMore() {
        if (!hasMore || fetching)
            return;

        fetchPage(currentPage + 1);
    }

    function fetchPage(pageNum) {
        if (fetching)
            return;

        fetching = true;

        var params = ["atleast=1920x1080", "ratios=16x9", "sorting=" + (query === "" ? "toplist" : "relevance"), "page=" + pageNum];
        if (query !== "")
            params.push("q=" + encodeURIComponent(query));

        var url = "https://wallhaven.cc/api/v1/search?" + params.join("&");

        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE)
                return;

            fetching = false;
            if (xhr.status !== 200) {
                console.warn("wallhaven:", xhr.status, xhr.statusText);
                return;
            }
            try {
                var json = JSON.parse(xhr.responseText);
                var data = json.data || [];
                if (pageNum === 1) {
                    results = data;
                } else {
                    var copy = results.slice();
                    for (var i = 0; i < data.length; i++) copy.push(data[i]);
                    results = copy;
                }
                currentPage = pageNum;
                if (json.meta) {
                    lastPage = json.meta.last_page || 1;
                    hasMore = currentPage < lastPage;
                }
            } catch (e) {
                console.warn("wallhaven parse error:", e);
            }
        };
        xhr.send();
    }

    function setWallpaper(url) {
        if (downloading)
            return;

        currentUrl = url;
        downloading = true;
        // URL arrives as $1, so nothing needs shell-escaping.
        _downloader.command = ["sh", "-c", "set -e; d=\"${XDG_CACHE_HOME:-$HOME/.cache}/quickshell\"; mkdir -p \"$d\"; printf '%s' \"$1\" > \"$d/wallpaper_url\"; curl -sfL --max-time 60 \"$1\" -o \"$d/wallpaper.img.tmp\"; mv -f \"$d/wallpaper.img.tmp\" \"$d/wallpaper.img\"; printf 'file://%s' \"$d/wallpaper.img\"", "sh", url];
        _downloader.running = true;
    }
}
