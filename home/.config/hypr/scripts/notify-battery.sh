#!/usr/bin/env bash
# Battery notifier. Event-driven via `upower --monitor`.
# Emits only four events:
#   1. charging started      (AC plugged in)
#   2. charging stopped      (AC unplugged BEFORE reaching full)
#   3. fully charged         (reached 100% on AC)
#   4. battery low           (and critical, while discharging)
set -euo pipefail

BAT=$(upower -e | grep -m1 -E 'BAT|battery_' || true)
[ -z "$BAT" ] && exit 0

notify() {
    notify-send --app-name="battery" "$@"
}

# Parses upower output. Trims whitespace properly (unlike ${v## } which only
# removes a single space).
read_state() {
    upower -i "$BAT" | awk -F: '
        /^ *state:/      { gsub(/^[ \t]+|[ \t]+$/, "", $2); state = $2 }
        /^ *percentage:/ { gsub(/[ \t%]/, "", $2);          pct   = $2 }
        END              { print state ":" pct }
    '
}

last_state=""
warned=""          # ""|low|crit

handle() {
    local line state pct
    line=$(read_state)
    state=${line%:*}
    pct=${line#*:}
    [ -z "$state" ] && return

    if [ -n "$last_state" ] && [ "$state" != "$last_state" ]; then
        case "$last_state->$state" in
            *"->charging")
                notify --urgency=low "charging" "battery at ${pct}%"
                warned=""
                ;;
            "charging->discharging")
                notify --urgency=normal \
                    "charging stopped" "unplugged at ${pct}% — not full"
                ;;
            *"->fully-charged")
                notify --urgency=low "fully charged" "battery at 100%"
                ;;
        esac
    fi
    last_state="$state"

    if [ "$state" = "discharging" ]; then
        if [ "$pct" -le 5 ] && [ "$warned" != "crit" ]; then
            notify --urgency=critical --expire-time=0 \
                "battery critical" "${pct}% — plug in now"
            warned=crit
        elif [ "$pct" -le 15 ] && [ -z "$warned" ]; then
            notify --urgency=normal "battery low" "${pct}% remaining"
            warned=low
        fi
    else
        warned=""
    fi
}

# prime state (no notification emitted on first read)
handle

# upower --monitor prints one line per device event; we re-read on each
exec upower --monitor | while read -r _; do
    handle
done
