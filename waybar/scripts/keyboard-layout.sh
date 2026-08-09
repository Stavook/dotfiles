#!/usr/bin/env bash
# Streams the current keyboard layout (main keyboard) as JSON for waybar's custom module.

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

print_layout() {
    local keymap
    keymap=$(hyprctl devices | awk '
        /active keymap:/ { sub(/^[ \t]*active keymap:[ \t]*/, ""); km = $0 }
        /main: yes/ { print km; exit }
    ')
    local label
    case "$keymap" in
        "English (US)") label="EN" ;;
        "Greek")        label="GR" ;;
        *)              label="$keymap" ;;
    esac
    printf '{"text": "%s"}\n' "$label"
}

print_layout

nc -U "$SOCKET" | while read -r line; do
    [[ "$line" == activelayout* ]] && print_layout
done
