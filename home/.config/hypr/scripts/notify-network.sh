#!/usr/bin/env bash
# Wi-Fi connect/disconnect notifier. Event-driven via `nmcli monitor`.
set -euo pipefail

notify() {
    notify-send --app-name="Network" "$@"
}

wifi_ssid() {
    nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null \
        | awk -F: '$1=="yes"{print $2; exit}' || true
}

prev=$(wifi_ssid)

handle() {
    local cur
    cur=$(wifi_ssid)
    [ "$cur" = "$prev" ] && return
    if [ -n "$cur" ]; then
        notify --urgency=low "Wi-Fi connected" "$cur"
    elif [ -n "$prev" ]; then
        notify --urgency=normal "Wi-Fi disconnected" "Was: $prev"
    fi
    prev="$cur"
}

# nmcli monitor emits one line per NM state change
exec nmcli monitor 2>/dev/null | while read -r _; do
    handle
done
