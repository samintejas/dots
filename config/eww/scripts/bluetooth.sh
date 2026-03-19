#!/bin/bash
case "$1" in
    --icon)
        bluetoothctl show 2>/dev/null | grep -q "Powered: yes" && echo "󰂯" || echo "󰂲"
        ;;
    --status)
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            dev=$(bluetoothctl info 2>/dev/null | grep "Name:" | sed 's/.*Name: //')
            echo "${dev:-On}"
        else
            echo "Off"
        fi
        ;;
esac
