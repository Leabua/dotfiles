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

    # minimalBar's file preview plays video / audio (QtMultimedia) and reads webp,
    # tiff and avif (qtimageformats); the stock wrapper ships neither.
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

    # Everyday applications: terminal, file managers, productivity, and creative tools.
    google-chrome
    ghostty
    obsidian


    # Sidebar rows sit flush under Places / Devices: upstream pads them with a blank
    # 12px cell that the GTK theme can't reach.
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
    stow
    trash-cli
    wget
    yazi

    # Shell utilities: navigation, search, and terminal sessions.
    fd
    ripgrep
    tmux
    zoxide

    # External applications: packages supplied by pinned flake inputs.
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
