#!/usr/bin/env bash
# Wi-Fi network switcher via wofi dmenu, prompts for a password when needed.

declare -A ssid_for_entry
declare -A ssid_for_entry_seen

nmcli device wifi rescan >/dev/null 2>&1

while IFS=: read -r inuse ssid security signal; do
    [ -z "$ssid" ] && continue
    [ -n "${ssid_for_entry_seen[$ssid]}" ] && continue
    ssid_for_entry_seen[$ssid]=1

    if [ -n "$security" ] && [ "$security" != "--" ]; then
        icon="󰤆"
    else
        icon="󰤨"
    fi

    mark=""
    [ "$inuse" = "*" ] && mark=" (connected)"

    ssid_for_entry["$icon  $ssid  ${signal}%${mark}"]="$ssid"
done < <(nmcli -t -f IN-USE,SSID,SECURITY,SIGNAL device wifi list)

selected=$(printf '%s\n' "${!ssid_for_entry[@]}" | sort | wofi --dmenu --prompt "Wi-Fi")
[ -z "$selected" ] && exit 0

ssid="${ssid_for_entry[$selected]}"
[ -z "$ssid" ] && exit 0

output=$(nmcli device wifi connect "$ssid" 2>&1)
if [ $? -ne 0 ] && echo "$output" | grep -qi "secrets were required"; then
    password=$(wofi --dmenu --password --prompt "Password for $ssid")
    [ -n "$password" ] && nmcli device wifi connect "$ssid" password "$password"
fi
