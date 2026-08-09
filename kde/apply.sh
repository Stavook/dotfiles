#!/usr/bin/env bash
set -euo pipefail

# Merges specific keys into KDE's own sprawling config files (kwinrc,
# kglobalshortcutsrc, kdeglobals) via kwriteconfig6, instead of symlinking
# those files whole -- they mix in a lot of unrelated per-machine state we
# don't want to overwrite.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

apply_ini_fragment() {
  local fragment="$1" target="$2"
  local group=""
  while IFS= read -r line || [ -n "$line" ]; do
    [ -z "$line" ] && continue
    if [[ "$line" =~ ^\[(.*)\]$ ]]; then
      group="${BASH_REMATCH[1]}"
      continue
    fi
    kwriteconfig6 --file "$target" --group "$group" --key "${line%%=*}" "${line#*=}"
  done < "$fragment"
  echo "  applied $(basename "$fragment") -> $target"
}

echo "Applying Krohnkite settings + hotkeys, and Dwarven color scheme..."
apply_ini_fragment "$DOTFILES_DIR/kde/krohnkite-kwinrc.ini"     "$HOME/.config/kwinrc"
apply_ini_fragment "$DOTFILES_DIR/kde/krohnkite-shortcuts.ini"  "$HOME/.config/kglobalshortcutsrc"
kwriteconfig6 --file kdeglobals --group General --key ColorScheme Dwarven
echo "  applied Dwarven color scheme -> kdeglobals"

echo ""
echo "Reloading kwin (picks up Krohnkite settings + color scheme immediately)..."
qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || true

echo ""
echo "Note: keyboard shortcut changes don't reliably take effect until you"
echo "log out and back in (KDE's global shortcut grabber doesn't hot-reload)."
