#!/usr/bin/env bash
# Emits a desktop notification on Spotify track change, with album art.
set -euo pipefail

id=0
CACHE="${XDG_RUNTIME_DIR:-/tmp}/spotify-art"
mkdir -p "$CACHE"

playerctl -p spotify --follow metadata \
    --format '{{mpris:artUrl}}|{{artist}}|{{title}}|{{album}}' |
while IFS='|' read -r url artist title album; do
    [ -z "$title" ] && continue

    img=""
    if [ -n "$url" ]; then
        img="$CACHE/$(basename "$url").jpg"
        [ -f "$img" ] || curl -sL "$url" -o "$img" || img=""
    fi

    args=(
        --print-id
        --replace-id="$id"
        --app-name="Spotify"
        --urgency=low
        --category=x-gnome.music
        --expire-time=4000
        --hint=string:desktop-entry:spotify
    )
    if [ -n "$img" ] && [ -s "$img" ]; then
        args+=(--icon="$img" --hint=string:image-path:"$img")
    fi

    id=$(notify-send "${args[@]}" "♪ $title" "$artist — $album")
done
