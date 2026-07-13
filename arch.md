# Arch

The Arch counterpart to [`nixos/`](https://github.com/Leabua/dotfiles/tree/master/nixos). Nixos declares all of this in `configuration.nix` and `packages.nix`; on Arch you do it by hand. Work top to bottom and you land on the same system.

Assumes Arch is installed from the ISO, you have networking, and you're in the `wheel` group.

## 1. Packages

```
# base
sudo pacman -S base-devel git stow

# compositors + display manager
sudo pacman -S hyprland xorg-xwayland niri uwsm ly
sudo pacman -S hypridle hyprlock hyprpaper hyprsunset hyprshot hyprpolkitagent
sudo pacman -S xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# bar / shell / launchers / notifications  (walker + wlogout are AUR, below)
sudo pacman -S quickshell waybar rofi fuzzel mako

# wayland utilities
sudo pacman -S cliphist grim slurp satty wl-clipboard playerctl brightnessctl libnotify awww

# terminals
sudo pacman -S ghostty kitty alacritty

# shell
sudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search fzf zoxide

# terminal tools
sudo pacman -S tmux btop fastfetch yazi neovim lazygit ripgrep fd jq wget trash-cli tree-sitter

# audio
sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber pavucontrol rtkit wiremix

# network + bluetooth
sudo pacman -S networkmanager impala bluez bluez-utils bluetui

# power + graphics (intel; swap the driver if you're on amd/nvidia)
sudo pacman -S upower power-profiles-daemon intel-media-driver libvdpau-va-gl

# files + auth
sudo pacman -S nautilus gvfs udisks2 gnome-keyring

# theming
sudo pacman -S matugen gnome-themes-extra papirus-icon-theme nwg-look dconf

# fonts
sudo pacman -S ttf-iosevka-nerd ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji ttf-roboto

# dev + runtimes
sudo pacman -S python nodejs npm pnpm jdk-openjdk maven make cmake meson ninja rust

# lsp + formatters (matches packages.nix)
sudo pacman -S lua-language-server typescript-language-server tailwindcss-language-server qt6-declarative
sudo pacman -S stylua prettier python-black shfmt

# apps
sudo pacman -S firefox obs-studio obsidian

# misc
sudo pacman -S zram-generator
```

Then the AUR bits (install `yay` first if you haven't):

```
yay -S walker wlogout zsh-theme-powerlevel10k \
       otf-departure-mono otf-departure-mono-nerd \
       bibata-cursor-theme adwaita-qt5 adwaita-qt6 \
       zen-browser-bin claude-code pacseek \
       basedpyright jdtls vscode-langservers-extracted
```

`otf-departure-mono-nerd` is not optional if you use the Quickshell bar — the bar's glyphs are Nerd Font codepoints in DepartureMono. Note the bar wants the **non-Mono** `DepartureMono Nerd Font` family; the `Mono` variant squashes the wide icons.

`qt6-declarative` is what ships `qmlls`, the QML language server, which you want if you're editing the Quickshell configs in nvim.

## 2. Services

Nixos enables these with `services.<x>.enable = true`. On Arch:

```
sudo systemctl enable --now NetworkManager bluetooth
sudo systemctl enable --now power-profiles-daemon upower
sudo systemctl enable --now udisks2 sshd
sudo systemctl enable ly
```

Pipewire and wireplumber run as user services and start themselves — nothing to enable.

## 3. What Nixos does declaratively that Arch won't

These are the bits that live in `configuration.nix` and have no Arch equivalent, so they're easy to forget.

**Caps ↔ Escape, system wide** (`services.xserver.xkb.options`):
```
localectl set-x11-keymap us "" "" caps:swapescape
echo 'KEYMAP=us' | sudo tee /etc/vconsole.conf
```

**Power key opens the Quickshell power menu instead of shutting the machine down** (`services.logind.powerKey = "ignore"`) — in `/etc/systemd/logind.conf`:
```
HandlePowerKey=ignore
```

**zram swap** (`zramSwap.enable`) — in `/etc/systemd/zram-generator.conf`:
```
[zram0]
zram-size = ram / 2
```

**Session variables** (`environment.sessionVariables`) — in `/etc/environment`:
```
GTK_THEME=Adwaita:dark
QT_QPA_PLATFORM=wayland;xcb
LIBVA_DRIVER_NAME=iHD
EDITOR=nvim
VISUAL=nvim
BROWSER=zen-browser
```

**Shell** (`users.users.leabua.shell`):
```
chsh -s $(which zsh)
```

**Dark mode + icon theme** (the `dconf` block):
```
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark
```

**Trash cleanup timer** (the `trash-cleanup` systemd unit) — purges trashed files older than 20 days. Create `~/.config/systemd/user/trash-cleanup.service`:
```
[Service]
ExecStart=/usr/bin/trash-empty 20
```
and `~/.config/systemd/user/trash-cleanup.timer`:
```
[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```
then `systemctl --user enable --now trash-cleanup.timer`.

**Opening text files in nvim inside ghostty** (the `nvim-terminal` desktop item) — the stock `nvim.desktop` is `Terminal=true` and won't launch under Hyprland. Create `~/.local/share/applications/nvim-terminal.desktop`:
```
[Desktop Entry]
Type=Application
Name=Neovim (Terminal)
Exec=ghostty -e nvim %F
Terminal=false
Icon=nvim
Categories=Utility;TextEditor;
MimeType=text/plain;text/markdown;text/x-python;text/x-lua;text/javascript;application/json;
```
then set it as the default:
```
xdg-mime default nvim-terminal.desktop text/plain text/markdown text/x-python text/x-lua text/javascript application/json
```

## 4. Dots

```
git clone https://github.com/Leabua/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow alacritty bluetui btop fastfetch ghostty gtk hypr impala mako matugen niri nvim pacseek quickshell rofi satty tmux walker waybar wiremix yazi zsh
```

See the table in the [README](https://github.com/Leabua/dotfiles/blob/master/README.md) for what each one is.

## Notes

The dots are tuned for Nixos paths, so expect the odd hardcoded path to need fixing on Arch. Nothing structural.

`nix-output-monitor` is in `packages.nix` but has no Arch counterpart — it only exists to prettify `nixos-rebuild`, so there's nothing to install.
