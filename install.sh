#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUPS=()

# link <source-in-dotfiles> <target-path>
# Idempotent, non-destructive symlink creation. Used for every mapping below.
link() {
  local src="$1"
  local target="$2"

  if [ -L "$target" ] && [ "$(readlink -f "$target")" = "$(readlink -f "$src")" ]; then
    echo "  already linked: $target"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [ -e "$target" ] || [ -L "$target" ]; then
    local backup="${target}.bak"
    if [ -e "$backup" ] || [ -L "$backup" ]; then
      backup="${target}.bak.$(date +%Y%m%d%H%M%S)"
    fi
    echo "  backing up existing $target -> $backup"
    mv "$target" "$backup"
    BACKUPS+=("$backup")
  fi

  ln -s "$src" "$target"
  echo "  linked: $target -> $src"
}

echo "Bootstrapping dotfiles from $DOTFILES_DIR"

echo "== app config directories =="
link "$DOTFILES_DIR/waybar" "$HOME/.config/waybar"
link "$DOTFILES_DIR/kitty"  "$HOME/.config/kitty"
link "$DOTFILES_DIR/wofi"   "$HOME/.config/wofi"
link "$DOTFILES_DIR/zed"    "$HOME/.config/zed"
link "$DOTFILES_DIR/fastfetch" "$HOME/.config/fastfetch"

echo "== zsh =="
link "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

echo "== KDE (individual files only) =="
link "$DOTFILES_DIR/kde/Dwarven.colors" "$HOME/.local/share/color-schemes/Dwarven.colors"
link "$DOTFILES_DIR/kde/kwinrulesrc"    "$HOME/.config/kwinrulesrc"
link "$DOTFILES_DIR/kde/kxkbrc"         "$HOME/.config/kxkbrc"

if command -v kwriteconfig6 &>/dev/null; then
  "$DOTFILES_DIR/kde/apply.sh"
else
  echo "  kwriteconfig6 not found -- skipping Krohnkite settings/hotkeys/color scheme."
  echo "  Run kde/apply.sh manually once KDE tools are available."
fi

echo "== zen browser =="
zen_profiles_ini="$HOME/.config/zen/profiles.ini"

if [ ! -f "$zen_profiles_ini" ]; then
  echo "  Zen has never been run (no profiles.ini found)."
  echo "  Launch Zen once to create a default profile, then re-run this script."
else
  # The [InstallXXXX] section's Default= is the profile Zen/Firefox actually
  # uses, and takes precedence over any [ProfileN] Default=1 flag.
  install_default_path=$(awk '
    /^\[Install/ { f=1; next }
    /^\[/        { f=0 }
    f && /^Default=/ { sub(/^Default=/, ""); print; exit }
  ' "$zen_profiles_ini")

  if [ -z "$install_default_path" ]; then
    echo "  Could not find an [Install...] Default= entry in profiles.ini."
    echo "  Skipping zen chrome symlink -- check ~/.config/zen/profiles.ini manually."
  else
    zen_profile_dir="$HOME/.config/zen/$install_default_path"
    if [ ! -d "$zen_profile_dir" ]; then
      echo "  Default profile dir does not exist yet: $zen_profile_dir"
      echo "  Launch Zen once, then re-run this script."
    else
      link "$DOTFILES_DIR/zen/chrome" "$zen_profile_dir/chrome"
    fi
  fi
fi

echo ""
if [ "${#BACKUPS[@]}" -gt 0 ]; then
  echo "Backed up ${#BACKUPS[@]} pre-existing file(s)/dir(s):"
  for b in "${BACKUPS[@]}"; do
    echo "  - $b"
  done
else
  echo "No backups were needed."
fi
echo "Done."
