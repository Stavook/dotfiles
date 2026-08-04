#!/usr/bin/env bash
# Audio output (sink) switcher via wofi dmenu, icon depends on device type.

declare -A name_for_entry

while IFS=$'\t' read -r _ name _; do
    desc=$(pactl list sinks | awk -v n="$name" '
        $0 ~ ("Name: " n) { found=1 }
        found && /Description:/ { sub(/^[ \t]*Description: /, ""); print; exit }
    ')
    case "$desc" in
        *[Hh]eadphone*|*[Hh]eadset*) icon="󰋋" ;;
        *) icon="󰕾" ;;
    esac
    name_for_entry["$icon  $desc"]="$name"
done < <(pactl list short sinks)

selected=$(printf '%s\n' "${!name_for_entry[@]}" | wofi --dmenu --prompt "Audio Output")

[ -n "$selected" ] && pactl set-default-sink "${name_for_entry[$selected]}"
