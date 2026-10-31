# dotfiles

Personal config for Arch + Hyprland (Wayland).

## Structure

- `aether/` — templates that let Aether color waybar, wofi, mako, kitty,
  Hyprland borders, hyprlock, Zed, Dolphin, GTK apps (including file pickers),
  Zen and Vesktop
- `hypr/` — Hyprland config (`hyprland.lua`, `hypridle.conf`, `hyprlock.conf`)
- `waybar/` — status bar (modules, styles, scripts)
- `wofi/` — app launcher + power/audio/network menus
- `kitty/` — terminal
- `zed/` — editor
- `fastfetch/` — system info fetch config + ASCII logo
- `zsh/` — `.zshrc`, `.p10k.zsh`
- `zen/chrome/` — Zen browser userChrome/userContent
- `qt6ct/` — template for the Qt style (Fusion) and font; Aether's hook fills in
  the icon theme and the palette
- `fontconfig/` — default font substitution (JetBrainsMono Nerd Font)
- `sddm/` — login screen theme (colors and background come from Aether)

## How theming works

Aether is the only source of colors, the wallpaper and the icon variant. Pick or
generate a theme in the Aether app and everything below follows: waybar, wofi,
mako, kitty, Hyprland borders, hyprlock, Zed, Dolphin and Qt apps, GTK apps and
file pickers, Zen, Vesktop, the wallpaper (hyprpaper) and the SDDM login screen.
Each app has a template in `aether/custom/` and, where needed, a hook that
reloads it. Your saved themes live in `~/.config/aether/` (not in this repo);
copy `~/.config/aether/blueprints/` to bring them to another machine.

## Setup

On a new machine, in this order:

1. **Older setup?** If the machine had the Kvantum/Breeze-based setup, clean it
   up first (see [Moving from an older setup](#moving-from-an-older-setup)).
2. **Clone:** `git clone <this-repo> ~/dotfiles`
3. **Install packages:** the [Prerequisites](#prerequisites) below.
4. **Link configs:** `~/dotfiles/install.sh`. It symlinks every config into
   place, is safe to re-run, and backs up any pre-existing real config
   instead of overwriting it.
5. **Login screen** (needs sudo once): `~/dotfiles/sddm/setup.sh`. It installs the
   theme into a directory you own, so every Aether apply updates the login
   screen's colors and background.
6. **Aether:** copy your saved themes to `~/.config/aether/blueprints/` if you
   have them, open Aether, enable the `kitty`, `hyprlock` and `vencord` apps
   and disable the built-in `hyprland` and `mako` apps (`aether/custom/` replaces
   them), then apply a theme. `install.sh` never picks one, so it can't
   overwrite yours.
7. **Vesktop:** Settings → Themes → enable `aether.theme.css` (Discord needs
   internet to load the theme's base stylesheet).
8. **Log out and back in.** The Qt and GTK environment variables are read at
   session start.

## Prerequisites

```
sudo pacman -S hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent \
  hypridle hyprlock hyprpaper mako grim slurp wl-clipboard brightnessctl \
  waybar kitty wofi zed zsh fastfetch dolphin \
  playerctl wireplumber pipewire pipewire-pulse pipewire-alsa pipewire-jack pipewire-audio \
  qt6ct qt5-wayland qt6-wayland \
  ttf-jetbrains-mono-nerd papirus-icon-theme python-pillow networkmanager dbus
```

AUR (via `yay`/`paru`):

```
yay -S zen-browser-bin zsh-theme-powerlevel10k-git aether yaru-icon-theme
```

## Moving from an older setup

If the machine had the earlier Kvantum/Breeze-based setup, remove what would
fight this one, then run `install.sh` (it backs up anything it would overwrite
as `.bak`):

```
sudo pacman -Rns kvantum kvantum-qt5 mpvpaper nwg-look
```

Also remove `plasma-integration`, `kde-gtk-config` and `breeze-gtk` if present,
and delete the leftovers:

- `~/.config/Kvantum/`
- `~/.config/qt6ct/colors/Dwarven.conf` and `~/.config/qt6ct/style-colors.conf`
- `~/.local/share/color-schemes/Dwarven.colors`
- Old Breeze files in `~/.config/gtk-3.0/` and `~/.config/gtk-4.0/`
  (`colors.css`, `window_decorations.css`, `assets/`, `settings.ini`)
- Broken symlinks left by the pull: `~/.config/gtk-3.0/gtk.css`,
  `~/.config/qt6ct/qt6ct.conf`

Keep `qt6ct`, `papirus-icon-theme`, `adwaita-icon-theme` and `breeze-icons`
(a Dolphin dependency).

Notes:
- GTK apps use Adwaita's dark variant (`GTK_THEME` in `hypr/hyprland.lua`, also
  handed to the GTK portal at startup so file pickers come up dark); the
  colors come from `aether/custom/gtk3` and `gtk4`.
- Qt apps get their icon theme and palette from the Aether hooks, so
  `qt6ct/qt6ct.conf` is a template and isn't linked by `install.sh`.
