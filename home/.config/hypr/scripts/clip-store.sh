#!/usr/bin/env bash
# cliphist store, minus secrets. Run by `wl-paste --watch`; the clipboard
# content arrives on stdin. Password managers mark their copies with a hint
# mime type (KeePassXC, Bitwarden, 1Password, GNOME/KDE tools), so skip those.
# Everything else is stored; cliphist is capped to 300 entries.
if wl-paste --list-types 2>/dev/null | grep -qiE 'x-kde-passwordManagerHint|password'; then
    cat >/dev/null
    exit 0
fi
exec cliphist -max-items 300 store
