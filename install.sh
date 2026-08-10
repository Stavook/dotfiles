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
link "$DOTFILES_DIR/hypr/hyprland.lua"   "$HOME/.config/hypr/hyprland.lua"
link "$DOTFILES_DIR/hypr/hypridle.conf"  "$HOME/.config/hypr/hypridle.conf"
link "$DOTFILES_DIR/hypr/hyprlock.conf"  "$HOME/.config/hypr/hyprlock.conf"
link "$DOTFILES_DIR/hypr/toggle-hide.sh" "$HOME/.config/hypr/toggle-hide.sh"
link "$DOTFILES_DIR/mako"                "$HOME/.config/mako"
link "$DOTFILES_DIR/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
link "$DOTFILES_DIR/gtk-3.0/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
link "$DOTFILES_DIR/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
link "$DOTFILES_DIR/qt6ct/qt6ct.conf" "$HOME/.config/qt6ct/qt6ct.conf"
link "$DOTFILES_DIR/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"

if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme 'Default'
  gsettings set org.gnome.desktop.interface icon-theme 'YAMIS'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  echo "  set gsettings gtk-theme/icon-theme/color-scheme (some GTK apps, e.g. Thunar, read these instead of settings.ini)"
fi

echo "== zsh =="
link "$DOTFILES_DIR/zsh/.zshrc"    "$HOME/.zshrc"
link "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"

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
