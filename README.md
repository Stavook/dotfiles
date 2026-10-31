# dotfiles

Personal config for Arch + Hyprland (Wayland).

## Structure

- `aether/` — color source for waybar, wofi, mako, kitty, Hyprland borders,
  hyprlock, Zed and Qt/Dolphin (`dwarven.colors.toml` palette + `custom/`
  templates)
- `hypr/` — Hyprland config (`hyprland.lua`, `hypridle.conf`, `hyprlock.conf`)
- `waybar/` — status bar (modules, styles, scripts)
- `wofi/` — app launcher + power/audio/network menus
- `kitty/` — terminal
- `zed/` — editor
- `fastfetch/` — system info fetch config + ASCII logo
- `zsh/` — `.zshrc`, `.p10k.zsh`
- `zen/chrome/` — Zen browser userChrome/userContent
- `gtk-3.0/`, `gtk-4.0/` — GTK app theming/font
- `fontconfig/` — default font substitution (Hack Nerd Font)
- `qt6ct/` — Qt style (Fusion), font and icons; colors come from `aether/`
- `sddm/` — login screen theme

## Setup

```
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

Symlinks every config into place. Safe to re-run; backs up any pre-existing
real config instead of overwriting it.

## Prerequisites

```
sudo pacman -S hyprland xdg-desktop-portal-hyprland hyprpolkitagent \
  hypridle hyprlock hyprpaper mako grim slurp wl-clipboard \
  waybar kitty wofi zed zsh fastfetch dolphin \
  playerctl wireplumber pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-audio \
  qt6ct qt5-wayland qt6-wayland \
  ttf-hack-nerd networkmanager dbus
```

AUR (via `yay`/`paru`):

```
yay -S zen-browser-bin zsh-theme-powerlevel10k-git aether
```

## Manual steps (not handled by install.sh)

- **Aether app toggles**: in Aether's settings, enable kitty and hyprlock and
  disable the built-in hyprland and mako apps (`aether/custom/hyprland-lua`
  and `aether/custom/mako` replace them). Also enable the `vencord` app there.
- **Vesktop theme**: in Vesktop, Settings → Themes, enable `aether.theme.css`
  (`install.sh` links it; Discord needs internet to load the theme's base
  stylesheet).
- **SDDM login theme**:
  ```
  sudo cp -r sddm/Dwarven /usr/share/sddm/themes/dwarven
  sudo mkdir -p /etc/sddm.conf.d
  echo -e "[Theme]\nCurrent=dwarven" | sudo tee /etc/sddm.conf.d/theme.conf
  ```
