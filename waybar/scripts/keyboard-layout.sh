#!/usr/bin/env bash
# Streams the current KDE keyboard layout as JSON for waybar's custom module.

print_layout() {
    local index
    index=$(qdbus6 org.kde.keyboard /Layouts org.kde.KeyboardLayouts.getLayout)
    local code
    code=$(qdbus6 --literal org.kde.keyboard /Layouts org.kde.KeyboardLayouts.getLayoutsList \
        | grep -oP '\(sss\) "\K[a-z]+' | sed -n "$((index + 1))p")
    local label
    case "$code" in
        us) label="EN" ;;
        gr) label="GR" ;;
        *) label=$(echo "$code" | tr '[:lower:]' '[:upper:]') ;;
    esac
    printf '{"text": "%s"}\n' "$label"
}

print_layout

dbus-monitor --session "type='signal',interface='org.kde.KeyboardLayouts',member='layoutChanged'" 2>/dev/null |
while read -r line; do
    [[ "$line" == *"member=layoutChanged"* ]] && print_layout
done
