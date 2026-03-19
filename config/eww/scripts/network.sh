#!/bin/bash
# Network status and icon for eww widget

get_status() {
    local device type name
    device=$(nmcli -t -f DEVICE,TYPE,STATE dev status 2>/dev/null \
        | awk -F: '$3=="connected" && $1!="lo" {print $1; exit}')

    if [[ -z "$device" ]]; then
        echo "Offline"
        return
    fi

    type=$(nmcli -t -f DEVICE,TYPE dev status 2>/dev/null \
        | awk -F: -v d="$device" '$1==d {print $2; exit}')
    name=$(nmcli -t -f DEVICE,CONNECTION dev status 2>/dev/null \
        | awk -F: -v d="$device" '$1==d {print $2; exit}')

    case "$type" in
        ethernet) echo "Ethernet" ;;
        wifi)     echo "${name:-Wi-Fi}" ;;
        *)        echo "${name:-Connected}" ;;
    esac
}

get_icon() {
    local type
    type=$(nmcli -t -f DEVICE,TYPE,STATE dev status 2>/dev/null \
        | awk -F: '$3=="connected" && $1!="lo" {print $2; exit}')

    case "$type" in
        ethernet) echo "󰈀" ;;
        wifi)     echo "󰖩" ;;
        "")       echo "󰖪" ;;
        *)        echo "󰌐" ;;
    esac
}

case "$1" in
    --status) get_status ;;
    --icon)   get_icon ;;
    *) echo "Usage: $0 [--status|--icon]" ;;
esac
