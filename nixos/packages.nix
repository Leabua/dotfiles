{ pkgs, inputs, ... }:

{
    environment.systemPackages = with pkgs; [
        # desktop / system tools
        adwaita-qt
        adwaita-qt6
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
        hyprlock
        hyprpolkitagent
        jdk
        jq
        kitty
        libnotify
        matugen
        maven
        neovim
        obs-studio
        obsidian
        pavucontrol
        playerctl
        quickshell
        ripgrep
        satty
        slurp
        stow
        awww          # was swww; renamed upstream
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
        gnumake
        lua-language-server
        typescript-language-server
        vscode-langservers-extracted
        tailwindcss-language-server
        basedpyright
        jdt-language-server

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
        nerd-fonts.iosevka
        nerd-fonts.departure-mono
        departure-mono
    ];
}
