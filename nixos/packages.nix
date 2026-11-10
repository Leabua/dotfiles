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

    # Quickshell, plus QtMultimedia and extra image formats so minimalBar's
    # file preview can play video / audio and show webp images.
    (symlinkJoin {
      name = "quickshell-with-media";
      paths = [ quickshell ];
      nativeBuildInputs = [ makeWrapper ];
      postBuild = ''
        for bin in $out/bin/*; do
          wrapProgram "$bin" \
            --prefix NIXPKGS_QT6_QML_IMPORT_PATH : ${qt6.qtmultimedia}/lib/qt-6/qml \
            --prefix QT_PLUGIN_PATH : ${qt6.qtmultimedia}/lib/qt-6/plugins:${qt6.qtimageformats}/lib/qt-6/plugins
        done
      '';
    })
    poppler-utils # pdftoppm / pdfinfo render PDF pages for the preview

    # Capture and clipboard: screenshots, annotations, and clipboard history.
    cliphist
    grim
    satty
    slurp
    wl-clipboard

    # Everyday applications: browser, terminal, notes, and file manager.
    google-chrome
    ghostty
    obsidian

    # Thunar, patched so sidebar rows sit flush under Places / Devices: upstream
    # pads them with a blank 12px cell that the GTK theme can't reach.
    (thunar.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace thunar/thunar-shortcuts-view.c \
          --replace-fail 'g_object_set (G_OBJECT (renderer), "xpad", 6, NULL);' \
                         'g_object_set (G_OBJECT (renderer), "xpad", 0, NULL);'
      '';
    }))

    # System utilities: monitoring, dotfiles, downloads, and trash management.
    btop
    fastfetch
    nix-output-monitor
    nixd # Nix language server for Zed and Neovim
    stow
    trash-cli
    wget
    yazi

    # Shell utilities: navigation, search, and terminal sessions.
    fd
    ripgrep
    tmux
    zoxide
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-powerlevel10k
    zsh-syntax-highlighting
    herdr # from nixpkgs so it comes prebuilt; the herdr flake compiles Rust

    # Browsers and apps from flake inputs.
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default
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
