#!/usr/bin/env bash
# Aether runs hooks before it has finished writing the wallpaper, so wait for
# it and do the real work in a detached copy of this script.
if [ -z "$AETHER_HOOK_DEFERRED" ]; then
    AETHER_HOOK_DEFERRED=1 setsid "$0" >/dev/null 2>&1 </dev/null &
    exit 0
fi
sleep 3

# The SDDM greeter runs as its own user and can't read $HOME, so copy the
# generated colors and the wallpaper into the theme directory (made writable
# for you once by sddm/setup.sh). Does nothing until that setup has run.
dir="${AETHER_SDDM_DIR:-/usr/share/sddm/themes/aether}"
[ -w "$dir" ] || exit 0

theme="$HOME/.config/aether/theme"
wallpaper=$(ls -t "$theme/backgrounds/"* 2>/dev/null | head -1)

cp "$theme/sddm-theme.conf.user" "$dir/theme.conf.user"
rm -f "$dir"/background.*
if [ -n "$wallpaper" ]; then
    # Blur and dim it like the lock screen so the text stays readable.
    python3 -I -W ignore - "$wallpaper" "$dir/background.jpg" <<'PY'
import sys
from PIL import Image, ImageEnhance, ImageFilter
im = Image.open(sys.argv[1]).convert("RGB")
im.thumbnail((2560, 2560))
im = im.filter(ImageFilter.GaussianBlur(10))
im = ImageEnhance.Brightness(im).enhance(0.45)
im.save(sys.argv[2], "JPEG", quality=90)
PY
    echo "background=background.jpg" >> "$dir/theme.conf.user"
fi
chmod a+r "$dir"/*
exit 0
