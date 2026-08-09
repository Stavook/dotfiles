# dotfiles

Personal config for Arch + KDE Plasma (Wayland).

## Structure

- `waybar/` — status bar (modules, styles, scripts)
- `kitty/` — terminal
- `wofi/` — app launcher + power/audio menus
- `zed/` — editor
- `fastfetch/` — system info fetch config + ASCII logo
- `zsh/` — `.zshrc`, `.p10k.zsh`
- `kde/` — `kwinrulesrc`, `kxkbrc`, `Dwarven.colors` color scheme
- `zen/chrome/` — Zen browser userChrome/userContent

## Setup

```
git clone <this-repo> ~/dotfiles
~/dotfiles/install.sh
```

Symlinks every config into place. Safe to re-run; backs up any pre-existing
real config instead of overwriting it. Does not install packages.

## Prerequisites

KDE Plasma is assumed (kwin, systemsettings).

```
sudo pacman -S waybar kitty wofi zed zsh fastfetch playerctl qt6-tools wireplumber libpulse dbus ttf-hack-nerd
```

AUR (via `yay`/`paru`):

```
yay -S zen-browser-bin zsh-theme-powerlevel10k-git
```

## Zen browser

`zen/chrome` gets symlinked into your default profile's `chrome/` dir by
`install.sh`, which reads `~/.config/zen/profiles.ini` to find it. If Zen
hasn't been run yet on this machine, launch it once (to create the profile)
and re-run `install.sh`.
