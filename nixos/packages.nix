{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Desktop appearance: themes, icons, cursors, and wallpaper colors.
    adwaita-qt
    adwaita-qt6
    awww
    bibata-cursors
    gnome-themes-extra
    matugen
    papirus-icon-theme

    # Desktop controls: notifications, media, audio, brightness, and session locking.
    brightnessctl
    hypridle
    hyprlock
    hyprpolkitagent
    libnotify
    pavucontrol
    playerctl
    quickshell

    # Capture and clipboard: screenshots, annotations, and clipboard history.
    cliphist
    grim
    satty
    slurp
    wl-clipboard

    # Everyday applications: terminal, file managers, productivity, and creative tools.
    google-chrome
    ghostty
    libreoffice
    obs-studio
    obsidian
    thunar
    t3code
    yazi

    # System utilities: monitoring, dotfiles, downloads, and trash management.
    btop
    fastfetch
    nix-output-monitor
    stow
    trash-cli
    wget

    # Shell utilities: navigation, search, and terminal sessions.
    fd
    # fzf and starship are installed by their NixOS modules.
    ripgrep
    tmux
    zoxide
    # zsh-autosuggestions
    # zsh-history-substring-search
    # zsh-powerlevel10k
    # zsh-syntax-highlighting

    # External applications: packages supplied by pinned flake inputs.
    inputs.clocktui.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop launcher: open associated text files in terminal Neovim.
    (makeDesktopItem {
      name = "nvim-terminal";
      desktopName = "Neovim (Terminal)";
      genericName = "Text Editor";
      exec = "ghostty -e nvim %F";
      terminal = false;
      icon = "nvim";
      categories = [
        "Utility"
        "TextEditor"
      ];
      mimeTypes = [
        "text/plain"
        "text/markdown"
        "text/x-python"
        "text/x-lua"
        "text/javascript"
        "application/json"
      ];
      startupNotify = false;
    })
  ];
}
