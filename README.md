# dotfiles

Personal config for Arch + Hyprland (Wayland).

## Structure

- `hypr/` — Hyprland config (`hyprland.lua`, `hypridle.conf`, `hyprlock.conf`)
- `waybar/` — status bar (modules, styles, scripts)
- `wofi/` — app launcher + power/audio menus
- `mako/` — notification daemon
- `kitty/` — terminal
- `zed/` — editor
- `fastfetch/` — system info fetch config + ASCII logo
- `zsh/` — `.zshrc`, `.p10k.zsh`
- `zen/chrome/` — Zen browser userChrome/userContent
- `gtk-3.0/`, `gtk-4.0/` — GTK app theming/font
- `fontconfig/` — default font substitution (Hack Nerd Font)
- `qt6ct/`, `kvantum/` — Qt app theming (Dolphin, CoreCtrl, Stremio)
- `colorschemes/` — Dwarven KDE color scheme (needed by Dolphin specifically)
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
  hypridle hyprlock mako mpvpaper grim slurp wl-clipboard \
  waybar kitty wofi zed zsh fastfetch dolphin \
  playerctl wireplumber pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-audio \
  qt6ct qt5-wayland qt6-wayland kvantum kvantum-qt5 \
  ttf-hack-nerd networkmanager dbus
```

AUR (via `yay`/`paru`):

```
yay -S zen-browser-bin zsh-theme-powerlevel10k-git
```

## Manual steps (not handled by install.sh)

- **Kvantum theme** — open `kvantummanager`, install the theme from
  `kvantum/Dwarven/`, select it, and set `style=kvantum` in `qt6ct`'s
  Appearance tab.
- **SDDM login theme**:
  ```
  sudo cp -r sddm/Dwarven /usr/share/sddm/themes/dwarven
  sudo mkdir -p /etc/sddm.conf.d
  echo -e "[Theme]\nCurrent=dwarven" | sudo tee /etc/sddm.conf.d/theme.conf
  ```
