#!/usr/bin/env bash
# Flip the OS colour scheme between Dots dark and Dots light.
#
# The quickshell theme (mode "system") and GTK 4 / libadwaita apps follow
# org.gnome.desktop.interface color-scheme, so this one key re-themes both.
# The terminal, GTK 3, hyprlock and Hyprland borders stay dark: the design
# system defines the terminal palette for dark only.
set -euo pipefail

key=org.gnome.desktop.interface
if [[ "$(gsettings get "$key" color-scheme)" == "'prefer-light'" ]]; then
    gsettings set "$key" color-scheme prefer-dark
else
    gsettings set "$key" color-scheme prefer-light
fi
