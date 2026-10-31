#!/usr/bin/env bash
# Aether only picks the closest Yaru variant (see the `name` template); it
# doesn't apply it. Set it for GTK (gsettings), KDE (kdeglobals) and Qt
# (qt6ct.conf). Falls back to Papirus-Dark if the Yaru variant isn't installed.
repo="$(cd "$(dirname "$(readlink -f "$0")")/../../.." && pwd)"
name="$(cat "$HOME/.config/aether/theme/icon-theme-name" 2>/dev/null)"
dirs="${ICON_DIRS:-/usr/share/icons $HOME/.local/share/icons}"

chosen=""
for cand in "$name-dark" "$name" Papirus-Dark; do
    [ "$cand" = "-dark" ] && continue
    for d in $dirs; do
        if [ -d "$d/$cand" ]; then chosen="$cand"; break 2; fi
    done
done
[ -z "$chosen" ] && exit 0

if [ -n "$DRY_RUN" ]; then echo "$chosen"; exit 0; fi

gsettings set org.gnome.desktop.interface icon-theme "$chosen"
kwriteconfig6 --file kdeglobals --group Icons --key Theme "$chosen"

# qt6ct has no way to follow an external setting, so render its config from
# the repo template. Replace any old symlink instead of writing through it.
mkdir -p "$HOME/.config/qt6ct"
rm -f "$HOME/.config/qt6ct/qt6ct.conf"
sed "s/@ICON@/$chosen/" "$repo/qt6ct/qt6ct.conf" > "$HOME/.config/qt6ct/qt6ct.conf"
exit 0
