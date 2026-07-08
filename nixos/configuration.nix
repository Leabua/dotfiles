{ config, lib, pkgs, inputs, ... }:

{
    imports =
        [
        ./hardware-configuration.nix
        ./packages.nix
        ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.kernelPackages = pkgs.linuxPackages_latest;

# systemwide caps <-> escape
    services.xserver.xkb.options = "caps:swapescape";
    console.useXkbConfig = true;

    zramSwap.enable = true;

    networking.hostName = "nixos"; # Define your hostname.
    networking.networkmanager.enable = true;

    time.timeZone = "Africa/Johannesburg";

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
#jack.enable = true;
    };

    services.libinput.enable = true;

# backing services for the quickshell bar widgets
    services.upower.enable = true;                 # battery
    services.power-profiles-daemon.enable = true;  # power profiles
    hardware.bluetooth.enable = true;              # bluetooth

    users.users.leabua = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
    };

# List services that you want to enable:
    services.displayManager.ly.enable = true;
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };

# hyprpolkitagent ships a user systemd unit (WantedBy=graphical-session.target)
# rather than a plain binary on PATH, so it's wired via systemd, not autostart.lua
    systemd.packages = with pkgs; [ hyprpolkitagent ];
    systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

    programs.firefox.enable = true;
    services.openssh.enable = true;

    programs.zsh.enable = true;
    users.users.leabua.shell = pkgs.zsh;
    environment.pathsToLink = [
        "/share/fzf"
        "/share/zsh-powerlevel10k"
        "/share/zsh-autosuggestions"
        "/share/zsh-syntax-highlighting"
        "/share/zsh-history-substring-search"
    ];

    # Forcing dark mode via session variables (better for Wayland/Hyprland)
    environment.sessionVariables = {
        GTK_THEME = "Adwaita:dark";
        QT_QPA_PLATFORM = "wayland;xcb";
    };

    programs.dconf.enable = true;

    qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
    };

    programs.dconf.profiles.user.databases = [{
        settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
            };
        };
    }];

    xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.common.default = "*";
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;

    system.stateVersion = "26.05";
}
