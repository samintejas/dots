#!/bin/bash
case "$1" in
    --icon)
        info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
        if echo "$info" | grep -q "MUTED"; then
            echo "󰝟"
        else
            vol=$(echo "$info" | awk '{printf "%.0f", $2*100}')
            if   (( vol > 60 )); then echo "󰕾"
            elif (( vol > 20 )); then echo "󰖀"
            else                      echo "󰕿"
            fi
        fi
        ;;
    *)
        wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{printf "%.0f", $2*100}' || echo 0
        ;;
esac
