# New System Setup

## Base
```
sudo pacman -S base base-devel linux linux-firmware git stow
```

## Display Manager
```
sudo pacman -S ly
sudo systemctl enable ly
```

## Wayland Compositors
```
sudo pacman -S hyprland hypridle hyprlock hyprsunset hyprshot hyprpaper uwsm niri
```

## Desktop Utilities
```
sudo pacman -S xdg-desktop-portal-hyprland fuzzel wlogout nwg-look cliphist grim slurp satty awww
```

## Terminal
```
sudo pacman -S ghostty alacritty
```

## Shell
```
sudo pacman -S zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search fzf zoxide
yay -S zsh-theme-powerlevel10k
chsh -s $(which zsh)
```

## Terminal Tools
```
sudo pacman -S tmux btop fastfetch yazi neovim lazygit ripgrep fd
```

## Bluetooth
```
sudo pacman -S bluez bluez-utils bluetui
sudo systemctl enable bluetooth
```

## Audio
```
sudo pacman -S pipewire pipewire-pulse wireplumber pavucontrol
```

## Networking
```
sudo pacman -S networkmanager network-manager-applet nm-connection-editor
sudo systemctl enable NetworkManager
```

## Notifications
```
sudo pacman -S mako
```

## Theming & Fonts
```
sudo pacman -S matugen ttf-jetbrains-mono-nerd ttf-iosevka-nerd ttf-zed-mono-nerd ttf-nerd-fonts-symbols ttf-roboto noto-fonts noto-fonts-emoji adwaita-icon-theme adwaita-cursors
yay -S bibata-cursor-theme-bin apple-fonts
```

## File Management
```
sudo pacman -S nautilus gvfs udisks2
```

## Authentication
```
sudo pacman -S gnome-keyring polkit-kde-agent
```

## Development
```
sudo pacman -S python-pip nodejs npm rust cmake meson ninja
```

## App Launchers
```
yay -S rofi-lbonn-wayland walker
```

## AUR Apps
```
yay -S pacseek impala wiremix quickshell
```

## System Utilities
```
sudo pacman -S brightnessctl
```

## Dotfiles (GNU Stow)
```
cd ~/.dotfiles
stow alacritty bluetui btop fastfetch ghostty hypr impala mako matugen niri nvim pacseek quickshell rofi satty tmux walker waybar wiremix yazi zsh
```
