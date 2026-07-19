{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    adwaita-qt
      adwaita-qt6
      awww          
      bibata-cursors
      brightnessctl
      btop
      bun
      claude-code
      cliphist
      fastfetch
      fd
      fzf
      gcc
      git
      ghostty
      glib
      gnome-themes-extra
      google-chrome
      grim
      hypridle
      hyprlock
      hyprpolkitagent
      jdk
      jq
      kitty
      lazygit
      libnotify
      matugen
      maven
      nix-output-monitor # give me some visual for the nix rebuilds and upgrades
      neovim
      obs-studio
      obsidian
      papirus-icon-theme  
      pavucontrol
      playerctl
      pnpm
      qt6.qtdeclarative   # ships the `qmlls` QML language server (for Quickshell/QML in nvim)
      quickshell
      ripgrep
      satty
      slurp
      stow
      tmux
      trash-cli
      tree-sitter
      wget
      wl-clipboard
      yazi
      zoxide
      zsh-powerlevel10k
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-history-substring-search

# languages and runtimes
      go
      nodejs
      python3

# lsp
      basedpyright
      gnumake
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
