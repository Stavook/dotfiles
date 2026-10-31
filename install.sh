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
link "$DOTFILES_DIR/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"

if command -v gsettings &>/dev/null; then
  gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
  gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
  gsettings set org.gnome.desktop.interface font-name 'JetBrainsMono Nerd Font 10'
  gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  echo "  set gsettings theme/icons/fonts"
fi

# KDE Frameworks apps (Dolphin) read icons and fonts from kdeglobals, which
# takes precedence over qt6ct.
if command -v kwriteconfig6 &>/dev/null; then
  kde_font="JetBrainsMono Nerd Font,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1,,0,0"
  kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
  for key in font fixed menuFont toolBarFont; do
    kwriteconfig6 --file kdeglobals --group General --key "$key" "$kde_font"
  done
  kwriteconfig6 --file kdeglobals --group General --key smallestReadableFont "${kde_font/,10,/,8,}"
  echo "  set kdeglobals icon theme and fonts"
fi

echo "== aether (colors for waybar/wofi/mako/kitty/hyprland/hyprlock/zed/dolphin/zen/vesktop) =="
link "$DOTFILES_DIR/aether/custom" "$HOME/.config/aether/custom"

# Older installs symlinked ~/.config/mako into the repo. Aether now symlinks
# its rendered mako config into a real ~/.config/mako directory instead.
[ -L "$HOME/.config/mako" ] && rm "$HOME/.config/mako"
mkdir -p "$HOME/.config/mako"

# No theme is applied here on purpose, so re-running install.sh never overwrites
# the one you picked. On a new machine, open Aether and apply a theme once.
if ! command -v aether &>/dev/null; then
  echo "  aether not installed -- colors won't be generated until it is"
elif [ ! -f "$HOME/.config/aether/theme/colors.toml" ]; then
  echo "  no Aether theme applied yet -- open Aether and apply one"
fi

# Aether only writes the Vencord theme into its own dir; Vesktop reads
# ~/.config/vesktop/themes. Enable "aether.theme.css" in Vesktop's settings.
link "$HOME/.config/aether/theme/vencord.theme.css" "$HOME/.config/vesktop/themes/aether.theme.css"

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
