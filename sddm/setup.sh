#!/usr/bin/env bash
# One-time SDDM setup. Needs sudo. Makes the theme directory writable by you so
# Aether can update its colors and background automatically on every apply.
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dir=/usr/share/sddm/themes/aether

sudo mkdir -p "$dir"
sudo chown "$USER": "$dir"
cp -r "$DOTFILES_DIR/sddm/aether/." "$dir/"

sudo mkdir -p /etc/sddm.conf.d
printf '[Theme]\nCurrent=aether\n' | sudo tee /etc/sddm.conf.d/theme.conf >/dev/null

# Old theme from before the Aether port.
sudo rm -rf /usr/share/sddm/themes/dwarven

# Fill in the current Aether colors and wallpaper right away.
"$DOTFILES_DIR/aether/custom/sddm/post-apply.sh"
echo "SDDM theme installed. Test with: sddm-greeter-qt6 --test-mode --theme $dir"
