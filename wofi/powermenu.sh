#!/usr/bin/env bash
# Power menu via wofi dmenu, driven by the custom/power waybar module.

entries="󰌾  Lock
󰍃  Logout
󰤄  Suspend
󰜉  Reboot
󰐥  Shutdown"

selected=$(echo "$entries" | wofi --dmenu --prompt "Power" | awk '{$1=""; print $0}' | xargs)

case "$selected" in
    "Lock")
        loginctl lock-session
        ;;
    "Logout")
        qdbus6 org.kde.ksmserver /KSMServer logout 0 0 0
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
esac
