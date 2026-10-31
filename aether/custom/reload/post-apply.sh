#!/usr/bin/env bash
# Aether runs hooks before it has finished writing the wallpaper, so wait for
# it and do the real work in a detached copy of this script.
if [ -z "$AETHER_HOOK_DEFERRED" ]; then
    AETHER_HOOK_DEFERRED=1 setsid "$0" >/dev/null 2>&1 </dev/null &
    exit 0
fi
sleep 3

# Aether's Zed template uses "font_style": "underline", which Zed rejects
# (only normal/italic/oblique), so Zed drops the whole theme file.
sed -i 's/"font_style": "underline"/"font_style": null/' "$HOME/.config/zed/themes/aether.json"

# Outside Omarchy Aether only copies the wallpaper into theme/backgrounds/.
# Point hyprpaper at it (it only reads its config at startup, so restart it).
wallpaper=$(ls -t "$HOME/.config/aether/theme/backgrounds/"* 2>/dev/null | head -1)
if [ -n "$wallpaper" ]; then
    cat > "$HOME/.config/hypr/hyprpaper.conf" <<EOF
splash = false

wallpaper {
    monitor =
    path = $wallpaper
    fit_mode = cover
}
EOF
    pkill -x hyprpaper
    sleep 0.3
    setsid hyprpaper >/dev/null 2>&1 &

    # hyprlock reads its background path from here (sourced by hyprlock.conf).
    echo "\$wallpaper = $wallpaper" > "$HOME/.config/hypr/hyprlock-wallpaper.conf"
fi

# Reload apps that don't watch their generated theme files.
pkill -SIGUSR2 waybar
pkill -SIGUSR1 kitty
exit 0
