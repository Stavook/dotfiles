#!/usr/bin/env bash
# Open/closed state of the utilities drawer, for the handle's icon and color.
# Waybar exposes no such state itself, so a click toggles this file too. The
# waybar PID is stored with it because a restart always closes the drawer.

state="$HOME/.cache/waybar-drawer-state"
pid=$(pgrep -x waybar | head -1)

current=closed
if [ -f "$state" ]; then
    read -r saved_pid saved_state < "$state"
    [ "$saved_pid" = "$pid" ] && current="$saved_state"
fi

if [ "$1" = "toggle" ]; then
    [ "$current" = open ] && current=closed || current=open
    mkdir -p "$(dirname "$state")"
    printf '%s %s\n' "$pid" "$current" > "$state"
    pkill -RTMIN+11 waybar
    exit 0
fi

printf '{"text": "%s", "alt": "%s", "class": "%s"}\n' "$current" "$current" "$current"
