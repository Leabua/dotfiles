# Arch

Quick notes for going from a fresh `archinstall` to a working Niri/Hyprland session with these dots. Everything after that is done by hand.

## 1. pacman

Edit `/etc/pacman.conf` under `[options]`:

```
Color
ParallelDownloads = 5
ILoveCandy
```

Then uncomment the multilib block at the bottom so 32-bit packages work:

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

```
sudo pacman -Syu
```

## 2. Base + yay

```
sudo pacman -S --needed base-devel git stow
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin && makepkg -si
```

## 3. Enough to reach a graphical WM

```
# session
sudo pacman -S niri hyprland xorg-xwayland uwsm ly hyprlock hypridle hyprpolkitagent \
  xdg-desktop-portal-gtk xdg-desktop-portal-hyprland

# bar + its runtime bits
sudo pacman -S quickshell qt6-multimedia qt6-imageformats poppler matugen \
  cliphist wl-clipboard grim slurp satty brightnessctl playerctl libnotify awww

# audio / network / power / bluetooth
sudo pacman -S pipewire pipewire-pulse pipewire-alsa wireplumber \
  networkmanager network-manager-applet bluez bluez-utils upower power-profiles-daemon

# terminal + shell
sudo pacman -S ghostty tmux neovim zsh zsh-autosuggestions zsh-syntax-highlighting \
  zsh-history-substring-search fzf zoxide

# keyring / ssh agent / files
sudo pacman -S gnome-keyring gcr thunar gvfs udisks2 papirus-icon-theme
```

```
yay -S zsh-theme-powerlevel10k-git zen-browser-bin apple-fonts
```

Also grab Maple Mono NF and Pixelify Sans (hyprlock); check the AUR for both.

## 4. Services

```
sudo systemctl enable NetworkManager bluetooth upower power-profiles-daemon
sudo systemctl enable ly        # newer ly: ly@tty2 (and disable getty@tty2)
systemctl --user enable hyprpolkitagent gcr-ssh-agent.socket
chsh -s /usr/bin/zsh
```

Add `HandlePowerKey=ignore` to `/etc/systemd/logind.conf` so the power key opens the Quickshell menu.

## 5. Dots

```
git clone https://github.com/Leabua/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh ghostty tmux nvim niri hypr quickshell matugen gtk btop fastfetch herdr satty starship zed wallpapers
~/dotfiles/scripts/quickshell-icons   # builds the "Quickshell" icon theme
```

Reboot, pick a session in ly, done.

## Nix leftovers to fix once you're in

- `scripts/quickshell-icons`: Papirus path → `/usr/share/icons/Papirus-Dark` (fix this before running it)
- `btop.conf`: `color_theme` is a `/nix/store` path
- `hypr/.luarc.json`: stubs path is `/run/current-system/...`
- `hypr/modules/autostart.lua`: `hyprland-session.target` doesn't exist on Arch
- `.zshrc` / `.bashrc` aliases: rebuild/upgrade/clean/search are nix commands
- `.zshrc`: check the zsh-syntax-highlighting path against `pacman -Ql zsh-syntax-highlighting`
- nvim: LSPs aren't managed by Mason, so install the servers yourself with pacman/yay
