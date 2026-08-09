# dotfiles

Personal config for Arch + Hyprland (Wayland).

## Structure

- `waybar/` — status bar (modules, styles, scripts)
- `kitty/` — terminal
- `wofi/` — app launcher + power/audio menus
- `zed/` — editor
- `fastfetch/` — system info fetch config + ASCII logo
- `zsh/` — `.zshrc`, `.p10k.zsh`
- `zen/chrome/` — Zen browser userChrome/userContent
- `hypr/` — Hyprland config (`hyprland.lua`, `hypridle.conf`, `hyprlock.conf`)
- `mako/` — notification daemon config
- `gtk-3.0/`, `gtk-4.0/` — GTK app theming/font
- `fontconfig/` — default font substitution (Hack Nerd Font)

## Setup

```
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

Symlinks every config into place. Safe to re-run; backs up any pre-existing
real config instead of overwriting it. Does not install packages.

## Prerequisites

```
sudo pacman -S hyprland xdg-desktop-portal-hyprland waybar kitty wofi zed zsh \
  fastfetch playerctl wireplumber libpulse dbus ttf-hack-nerd \
  mpvpaper hypridle hyprlock mako grim slurp wl-clipboard qt6ct \
  networkmanager
```

AUR (via `yay`/`paru`):

```
yay -S zen-browser-bin zsh-theme-powerlevel10k-git
```

## Fonts

Hack Nerd Font is set as the default everywhere: `gtk-3.0`/`gtk-4.0`
`settings.ini` for GTK apps, `fontconfig/fonts.conf` for generic
sans-serif/serif/monospace substitution (covers apps with no explicit font
of their own), and `QT_QPA_PLATFORMTHEME=qt6ct` (set in `hyprland.lua`) so
Qt apps like Dolphin pick it up via `qt6ct` instead of needing a KDE
session.

## System tray

Waybar's own `tray` module hosts the `StatusNotifierWatcher`/`Host`
protocol itself — no separate tray daemon needed, despite the `org.kde.`
namespace in the D-Bus interface name (that's just the protocol's
historical naming, not an actual KDE dependency).

## Zen browser

`zen/chrome` gets symlinked into your default profile's `chrome/` dir by
`install.sh`, which reads `~/.config/zen/profiles.ini` to find it. If Zen
hasn't been run yet on this machine, launch it once (to create the profile)
and re-run `install.sh`.
