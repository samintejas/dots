#!/usr/bin/env bash
# Lock screen clock. Prints HH:MM with the colon blinking once a second.
#
# On an otherwise static lock screen this is the only thing that moves, so a
# glance tells you the machine is awake rather than hung. In a monospace font
# the space and the colon are the same width, so nothing jitters.
#
# %-S (no leading zero) matters: $((08 % 2)) is an octal error in bash.
set -euo pipefail

if (( $(date +%-S) % 2 == 0 )); then
    date +"%I:%M"
else
    date +"%I %M"
fi
