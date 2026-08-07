{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [

# QoL
    adwaita-qt
      adwaita-qt6
      awww
      bibata-cursors
      brightnessctl
      btop
      cliphist
      fastfetch
      gnome-themes-extra
      grim
      hypridle
      hyprlock
      hyprpolkitagent
      libreoffice
      libnotify
      matugen
      nix-output-monitor # give me some visual for the nix rebuilds and upgrades
      obs-studio
      obsidian
      papirus-icon-theme  
      pavucontrol
      playerctl
      qt6.qtdeclarative   # ships the `qmlls` QML language server (for Quickshell/QML in nvim)
      quickshell
      slurp
      stow
      thunar
      wget
      wl-clipboard
      yazi

# flakes
      inputs.helium.packages."${pkgs.stdenv.hostPlatform.system}".default
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

      (makeDesktopItem {
       name = "nvim-terminal";
       desktopName = "Neovim (Terminal)";
       genericName = "Text Editor";
       exec = "ghostty -e nvim %F";
       terminal = false;
       icon = "nvim";
       categories = [ "Utility" "TextEditor" ];
       mimeTypes = [ "text/plain" "text/markdown" "text/x-python" "text/x-lua" "text/javascript" "application/json" ];
       startupNotify = false;
       })
  ];

# fonts (system-wide, via fonts.packages not systemPackages)
  fonts.packages = with pkgs; [
    departure-mono
      maple-mono.NF
      nerd-fonts.departure-mono
      nerd-fonts.iosevka
  ];
}
