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
      libnotify
      matugen
      maven
      nautilus
      neovim
      obs-studio
      obsidian
      pavucontrol
      playerctl
      pnpm
      quickshell
      ripgrep
      satty
      slurp
      stow
      tmux
      tree-sitter
      wget
      wl-clipboard
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
      ];

# fonts (system-wide, via fonts.packages not systemPackages)
  fonts.packages = with pkgs; [
    departure-mono
      nerd-fonts.departure-mono
      nerd-fonts.iosevka
  ];
}
