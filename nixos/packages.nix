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
      docker
      fastfetch
      glib
      gnome-themes-extra
      google-chrome
      grim
      hypridle
      hyprlock
      hyprpolkitagent
      jdk
      jq
      lazygit
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

# dev tooling
      bun
      fd
      fzf
      gcc
      git
      ghostty
      opencode
      neovim
      ripgrep
      pnpm
      satty
      tmux
      trash-cli
      tree-sitter
      zoxide
      zsh-powerlevel10k
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-history-substring-search

# languages and runtimes
      go
      nodejs
      python3

#pyhton packages
      python314Packages.matplotlib
      python314Packages.numpy
      python314Packages.pandas
      python314Packages.yfinance

# c related
      gcc
      gnumake

# lsp
      basedpyright
      clang-tools
      gopls
      jdt-language-server
      lua-language-server
      tailwindcss-language-server
      typescript-language-server
      vscode-langservers-extracted


# conform -> formatters
      black
      prettier
      shfmt
      stylua

# flakes
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default
      inputs.antigravity-nix.packages."${pkgs.stdenv.hostPlatform.system}".default # Base App -> not the editor 

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
