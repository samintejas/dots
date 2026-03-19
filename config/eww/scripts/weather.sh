#!/bin/bash
# Weather from wttr.in — cached, supports --desc / --temp / --icon flags

CACHE="/tmp/.eww_weather_${USER}"
TTL=1800  # 30 minutes

refresh() {
    curl -sf --max-time 8 "https://wttr.in/?format=j1" > "${CACHE}.tmp" 2>/dev/null \
        && mv "${CACHE}.tmp" "$CACHE"
}

ensure_cache() {
    local age
    if [[ ! -f "$CACHE" ]]; then
        refresh
    else
        age=$(( $(date +%s) - $(stat -c %Y "$CACHE" 2>/dev/null || echo 0) ))
        (( age > TTL )) && refresh
    fi
}

parse() {
    local field="$1"
    [[ -f "$CACHE" ]] || { echo "N/A"; return; }
    python3 -c "
import sys, json

field = '$field'
with open('$CACHE') as f:
    d = json.load(f)
root = d.get('data', d)
c = root['current_condition'][0]
desc = c['weatherDesc'][0]['value']

if field == 'desc':
    print(desc)
elif field == 'temp':
    print(c['temp_C'] + '°C')
elif field == 'feels':
    print('feels ' + c['FeelsLikeC'] + '°C')
elif field == 'wind':
    print(c['windspeedKmph'] + ' km/h')
elif field == 'humidity':
    print(c['humidity'] + '%')
elif field == 'icon':
    dl = desc.lower()
    if any(w in dl for w in ['sunny', 'clear']):         icon = '󰖙'
    elif any(w in dl for w in ['partly', 'scattered']):  icon = '󰖕'
    elif any(w in dl for w in ['overcast', 'cloudy']):   icon = '󰖐'
    elif any(w in dl for w in ['thunder', 'storm']):     icon = '󰖓'
    elif any(w in dl for w in ['snow', 'sleet', 'bliz']): icon = '󰼶'
    elif any(w in dl for w in ['drizzle', 'light rain']): icon = '󰖗'
    elif any(w in dl for w in ['rain', 'shower']):       icon = '󰖖'
    elif any(w in dl for w in ['fog', 'mist', 'haze']):  icon = '󰖑'
    else:                                                 icon = '󰖐'
    print(icon)
" 2>/dev/null || echo "N/A"
}

ensure_cache

case "$1" in
    --desc)     parse desc ;;
    --temp)     parse temp ;;
    --feels)    parse feels ;;
    --wind)     parse wind ;;
    --humidity) parse humidity ;;
    --icon)     parse icon ;;
    *)
        parse desc
        echo "$(parse temp)  ·  $(parse feels)"
        echo "$(parse wind) wind  ·  $(parse humidity) humidity"
        ;;
esac
