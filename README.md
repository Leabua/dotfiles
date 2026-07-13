# Lea's dots for arch and nixos (hyprland and niri)
Simple set of modular dots that can get a whole system up in less than an hour. Using either Nixos or Arch. 
Dots are rather personal and currently tuned for Nixos file system currently, however when using arch most things will likely resolve and if there are any issues it will likely be a pathing issue that an LLM will likely be able to resolve.
Note: I assume that you'll do the part of figuring out how to install arch or nixos and getting it to a point that you can clone a repo. Same for learning what the packages that you'll need are. 

## Required packages 
stow  
git
hyprland or niri

## Getting Nixos up

The whole system is declared in [`nixos/`](https://github.com/Leabua/dotfiles/tree/master/nixos) as a flake. It is *not* stowed and does *not* live in `/etc/nixos` — you build straight out of the repo.

1. Install Nixos from the ISO as normal, then clone this repo to `~/dotfiles`.
2. Enable flakes if the installer hasn't, by adding to `/etc/nixos/configuration.nix`:
   `nix.settings.experimental-features = [ "nix-command" "flakes" ];` then `sudo nixos-rebuild switch`.
3. Copy your machine's real hardware config over the one in the repo — this file is specific to the machine that generated it and will not work on yours as-is:
```
cp /etc/nixos/hardware-configuration.nix ~/dotfiles/nixos/
```
4. Build it. The flake target is `#nixos`, which matches the hostname set in `configuration.nix` — change both if you want a different hostname.
```
sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos
```
5. Stow whatever configs you want from the table below.

Day to day there are aliases in [`zsh`](https://github.com/Leabua/dotfiles/tree/master/zsh) for this: `rebuild` to apply changes, `upgrade` to bump the flake inputs and rebuild, `clean` to garbage collect old generations.

Packages go in [`nixos/packages.nix`](https://github.com/Leabua/dotfiles/blob/master/nixos/packages.nix), not into an imperative `nix-env` install.

## Getting Arch up

Arch has no equivalent of `packages.nix`, so the whole thing is written out longhand in [`arch.md`](https://github.com/Leabua/dotfiles/blob/master/arch.md) — packages, services, and the handful of things Nixos does declaratively that you have to do by hand (caps↔escape, the power key, zram, session variables, the trash timer). Install Arch from the ISO, get networking up, then work top to bottom through it.

It's kept in step with `configuration.nix` and `packages.nix`, so the two systems land in the same place.

The dots themselves are tuned for Nixos paths, so on Arch expect the odd hardcoded path to need fixing. Nothing structural — usually a one-minute job.

## Usage
1. Flash either nixos or arch onto the system. Once internet is connected and operational install a window manager of your choice. 
2. Install the required packages above. 
3. Clone this repo down. 
You may need to setup git if you haven't yet.
```
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

```
Then: `git clone https://github.com/Leabua/dotfiles.git`. <- Now you have all the files on your system.

4. Stow usage 
Go into the cloned directory then:
Symlinking your configs
Recommended: `stow <folderName> `. I.e. `stow hypr` or for multiple files `stow hypr nvim tmux ghostty`.
Fastest and not recommended: `stow .` -> symlinks it all. Not recommeneded since thats just a mess since some packages do the same role.

Unstowing a directory
Go into the cloned repository. 
`stow -D <folderName>` <- removes the symlink (capital D; lowercase `-d` sets the stow directory instead)

You will be able to change the contents of anything either in dotfiles or in the actual place the files link to (likely ~/.config/ in most circumstances).

## Stowable packages

Every package below is stowed the same way — `stow <package>` from inside `~/dotfiles`, no flags. Pick only what you need, they're all independent.

Almost everything lands in `~/.config/<package>`. The only two exceptions are `zsh` (which drops `.zshrc` and `.p10k.zsh` straight into your home directory, since that's where zsh looks for them) and `wallpapers` (which lands at `~/Wallpapers`, since that's where `rotate_wallpaper.sh` looks).

| Package | What it does | Files |
| --- | --- | --- |
| `hypr` | Hyprland compositor: Lua modules for bindings, monitors, tiling and window rules, plus hyprlock / hypridle / hyprpaper / hyprsunset | [hypr](https://github.com/Leabua/dotfiles/tree/master/hypr/.config/hypr) |
| `niri` | Niri, the scrollable-tiling Wayland compositor — the alternative to Hyprland | [niri](https://github.com/Leabua/dotfiles/tree/master/niri/.config/niri) |
| `quickshell` | Custom QtQuick desktop shell: bar, menus, OSDs and launcher. Two bars live here, `minimalBar` and `onebarV2` | [quickshell](https://github.com/Leabua/dotfiles/tree/master/quickshell/.config/quickshell) |
| `waybar` | Status bar — the simpler alternative if you don't want Quickshell | [waybar](https://github.com/Leabua/dotfiles/tree/master/waybar/.config/waybar) |
| `nvim` | Neovim: LSP, plugins and colours | [nvim](https://github.com/Leabua/dotfiles/tree/master/nvim/.config/nvim) |
| `zsh` | Shell config with the powerlevel10k prompt (`.zshrc`, `.p10k.zsh`) | [zsh](https://github.com/Leabua/dotfiles/tree/master/zsh) |
| `tmux` | Terminal multiplexer | [tmux](https://github.com/Leabua/dotfiles/tree/master/tmux/.config/tmux) |
| `ghostty` | Terminal emulator — the daily driver | [ghostty](https://github.com/Leabua/dotfiles/tree/master/ghostty/.config/ghostty) |
| `alacritty` | Terminal emulator — the lightweight fallback | [alacritty](https://github.com/Leabua/dotfiles/tree/master/alacritty/.config/alacritty) |
| `matugen` | Generates the Material You colour palette from the current wallpaper; everything else reads its output | [matugen](https://github.com/Leabua/dotfiles/tree/master/matugen/.config/matugen) |
| `walker` | Wayland-native application launcher | [walker](https://github.com/Leabua/dotfiles/tree/master/walker/.config/walker) |
| `satty` | Screenshot annotation tool | [satty](https://github.com/Leabua/dotfiles/tree/master/satty/.config/satty) |
| `gtk` | GTK 3 and GTK 4 theme settings, so GTK apps match the rest | [gtk](https://github.com/Leabua/dotfiles/tree/master/gtk/.config) |
| `wallpapers` | The wallpaper collection — lands at `~/Wallpapers`, which is where `rotate_wallpaper.sh` looks | [wallpapers](https://github.com/Leabua/dotfiles/tree/master/wallpapers/Wallpapers) |
| `rofi` | Launcher and menus: app runner, clipboard, power menu | [rofi](https://github.com/Leabua/dotfiles/tree/master/rofi/.config/rofi) |
| `mako` | Lightweight Wayland notification daemon | [mako](https://github.com/Leabua/dotfiles/tree/master/mako/.config/mako) |
| `btop` | Resource monitor | [btop](https://github.com/Leabua/dotfiles/tree/master/btop/.config/btop) |
| `yazi` | Terminal file manager | [yazi](https://github.com/Leabua/dotfiles/tree/master/yazi/.config/yazi) |
| `wiremix` | TUI mixer for PipeWire audio | [wiremix](https://github.com/Leabua/dotfiles/tree/master/wiremix/.config/wiremix) |
| `impala` | TUI for wifi (iwd) | [impala](https://github.com/Leabua/dotfiles/tree/master/impala/.config/impala) |
| `bluetui` | TUI for bluetooth | [bluetui](https://github.com/Leabua/dotfiles/tree/master/bluetui/.config/bluetui) |
| `fastfetch` | System info on shell start | [fastfetch](https://github.com/Leabua/dotfiles/tree/master/fastfetch/.config/fastfetch) |
| `pacseek` | TUI for browsing the Arch repos and the AUR — Arch only, skip it on Nixos | [pacseek](https://github.com/Leabua/dotfiles/tree/master/pacseek/.config/pacseek) |

## Not stow packages

Two directories are in here but are not meant to be symlinked:

- [`nixos`](https://github.com/Leabua/dotfiles/tree/master/nixos) — the system config (`flake.nix`, `configuration.nix`, `packages.nix`). Rebuild straight from the repo, don't stow it.
- [`scripts`](https://github.com/Leabua/dotfiles/tree/master/scripts) — helper scripts. The configs call them by their repo path (`~/dotfiles/scripts/rotate_wallpaper.sh`), so they run in place.
