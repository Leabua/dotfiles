{ pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
# desktop / system tools
    adwaita-qt
      adwaita-qt6
      awww          
      btop
      brightnessctl
      bibata-cursors
      claude-code
      cliphist
      fastfetch
      fd
      fzf
      gcc
      git
      glib
      gnome-themes-extra
      ghostty
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
      neovim
      obs-studio
      obsidian
      papirus-icon-theme   # complete, crisp MIME/app icons desktop-wide (see icon-theme in configuration.nix)
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
      python3
      nodejs

# lsp
      basedpyright
      gnumake
      jdt-language-server
      lua-language-server
      tailwindcss-language-server
      typescript-language-server
      vscode-langservers-extracted

# conform -> formatters
      stylua
      prettier
      black
      shfmt

# flakes
      inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".default

# desktop entry so GUI apps open text files in nvim inside
# ghostty. Named nvim-terminal to avoid colliding with neovim's own nvim.desktop.
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
      nerd-fonts.departure-mono
      nerd-fonts.iosevka
  ];
}
