#!/usr/bin/env bash
# KDE apps (Dolphin) read colors from kdeglobals, not from the .colors file.
# Replace kdeglobals' color sections with the freshly generated scheme.
set -euo pipefail

scheme="$HOME/.local/share/color-schemes/Aether.colors"
globals="$HOME/.config/kdeglobals"
touch "$globals"

is_color_section='/^\[(Colors:|ColorEffects:|WM\])/'

tmp=$(mktemp)
awk "
    /^\[/ { skip = 0 }
    $is_color_section { skip = 1 }
    !skip
" "$globals" > "$tmp"

awk "
    /^\[/ { keep = 0 }
    $is_color_section { keep = 1 }
    keep
" "$scheme" >> "$tmp"

mv "$tmp" "$globals"

kwriteconfig6 --file kdeglobals --group General --key ColorScheme Aether
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme Aether
