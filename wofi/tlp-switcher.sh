#!/usr/bin/env bash
GPU_MODE_FILE="$HOME/.cache/gpu-mode"

entries="󰓅  Performance
󰗑  Balanced
󰾆  Power Saver"

selected=$(echo "$entries" | wofi --dmenu --prompt "Power Profile" | awk '{$1=""; print $0}' | xargs)

case "$selected" in
    "Performance")
        pkexec tlp performance
        echo "nvidia" > "$GPU_MODE_FILE"
        notify-send "Power Profile" "Performance (NVIDIA GPU)"
        ;;
    "Balanced")
        pkexec tlp balanced
        echo "nvidia" > "$GPU_MODE_FILE"
        notify-send "Power Profile" "Balanced (NVIDIA GPU)"
        ;;
    "Power Saver")
        pkexec tlp power-saver
        echo "radeon" > "$GPU_MODE_FILE"
        notify-send "Power Profile" "Power Saver (Radeon iGPU)"
        ;;
esac
