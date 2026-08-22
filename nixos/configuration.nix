{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [
    ./dev.nix
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

# vite needed this to let me see my local dev instance on other devices 
  networking.firewall.allowedTCPPorts = [ 5173 ];
  services.libinput.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   
        libvdpau-va-gl       
    ];
  };

  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/4fc12482-bbb3-4ced-a896-2b5f560c9f6b";
    fsType = "ext4";
    options = [
      "nofail"                          
        "x-systemd.device-timeout=5s"     
    ];
  };

# backend services for the quickshell bar widgets
  services.upower.enable = true;                 # battery
    services.power-profiles-daemon.enable = true;  # power profiles
    hardware.bluetooth.enable = true;              # bluetooth
    services.logind.settings.Login.HandlePowerKey = "ignore";  # stop logind powering off; let hyprland's XF86PowerOff bind open the quickshell powerMenu (long-press still forces off) -> changed this to the new convention

    users.users.leabua = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "kvm" ];
    };

# List services that you want to enable:
  services.displayManager.ly.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  systemd.packages = with pkgs; [ hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

  systemd.user.services.trash-cleanup.serviceConfig.ExecStart = "${pkgs.trash-cli}/bin/trash-empty 20";
  systemd.user.timers.trash-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;


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

# file manager backends (USB/udisks2 mounting, phone/MTP via gvfs)
  services.gvfs.enable = true;
  services.udisks2.enable = true;

# Forcing dark mode via session variables (better for Wayland/Hyprland)
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORM = "wayland;xcb";
    LIBVA_DRIVER_NAME = "iHD";
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "zen-beta";
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
        icon-theme = "Papirus-Dark";
      };
    };
  }];

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

# System-wide default apps (writes /etc/xdg/mimeapps.list). 
  xdg.mime.defaultApplications = {
    "inode/directory"   = "thunar.desktop";
    "text/plain"        = "nvim-terminal.desktop";
    "text/markdown"     = "nvim-terminal.desktop";
    "text/x-python"     = "nvim-terminal.desktop";
    "text/x-lua"        = "nvim-terminal.desktop";
    "text/javascript"   = "nvim-terminal.desktop";
    "application/json"  = "nvim-terminal.desktop";
# browser — declarative source of truth (mirrors the per-user file)
    "text/html"                = "zen-beta.desktop";
    "x-scheme-handler/http"    = "zen-beta.desktop";
    "x-scheme-handler/https"   = "zen-beta.desktop";
  };

  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "26.05";
}
