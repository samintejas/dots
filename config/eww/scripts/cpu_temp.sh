#!/bin/bash
# CPU temperature — scans common hwmon paths (adapted from gh0stzk/dotfiles)

PATHS="
/sys/class/thermal/thermal_zone*/temp
/sys/devices/platform/coretemp.*/hwmon/hwmon*/temp*_input
/sys/class/hwmon/hwmon*/temp*_input
/sys/devices/platform/thinkpad_hwmon/hwmon/hwmon*/temp*_input
"

max_temp=0

for pattern in $PATHS; do
    for file in $pattern; do
        [[ -f "$file" ]] || continue
        val=$(awk '{print int($1/1000)}' "$file" 2>/dev/null)
        [[ "$val" =~ ^[0-9]+$ ]] || continue
        (( val > max_temp )) && max_temp=$val
    done
done

if (( max_temp > 0 )); then
    echo "${max_temp}°C"
else
    echo "--°C"
fi
