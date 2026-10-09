{ pkgs, inputs, ... }:

{
  # Modules: hardware, applications, development tools, and optional gaming.
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./dev.nix
    # ./gaming.nix
    inputs.blip.nixosModules.default
  ];

  # Boot: UEFI bootloader and compressed RAM swap.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  zramSwap.enable = true;

  # Storage: optional data drive; boot can continue when it is absent.
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/4fc12482-bbb3-4ced-a896-2b5f560c9f6b";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };

  # Networking: host identity, NetworkManager, SSH, and local development ports.
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      5173
      1420
    ];
  };
  services.openssh.enable = true;
  programs.blip.enable = true;

  # Locale and input: local time and system-wide Caps Lock / Escape swap.
  time.timeZone = "Africa/Johannesburg";
  services.xserver.xkb.options = "caps:swapescape";
  console.useXkbConfig = true;
  services.libinput.enable = true;

  # Users and shell: account permissions and shared Zsh plugin paths.
  users.users.leabua = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "kvm"
      "docker"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
  environment.pathsToLink = [
    "/share/fzf"
    "/share/zsh-powerlevel10k"
    "/share/zsh-autosuggestions"
    "/share/zsh-syntax-highlighting"
    "/share/zsh-history-substring-search"
  ];

  # Desktop session: Ly greeter, Hyprland, and graphical privilege prompts.
  services.displayManager.ly.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  systemd.packages = [ pkgs.hyprpolkitagent ];
  systemd.user.services.hyprpolkitagent.wantedBy = [ "graphical-session.target" ];

  # Audio: PipeWire with PulseAudio and 32-bit ALSA compatibility.
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Graphics: Intel acceleration and compatibility for 32-bit applications.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  # Power and Bluetooth: backends for Quickshell widgets and the power menu.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  hardware.bluetooth.enable = true;
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Desktop integration: keyring, removable drives, and phone mounting.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Appearance and session defaults: dark GTK/Qt themes and preferred applications.
  environment.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORM = "wayland;xcb";
    LIBVA_DRIVER_NAME = "iHD";
    EDITOR = "nvim";
    VISUAL = "nvim";
    BROWSER = "zen-beta";
  };
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          icon-theme = "Papirus-Dark";
        };
      }
    ];
  };

  # Portals and file associations: desktop access and system-wide default handlers.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
  xdg.mime.defaultApplications = {
    "inode/directory" = "thunar.desktop";
    "text/plain" = "nvim-terminal.desktop";
    "text/markdown" = "nvim-terminal.desktop";
    "text/x-python" = "nvim-terminal.desktop";
    "text/x-lua" = "nvim-terminal.desktop";
    "text/javascript" = "nvim-terminal.desktop";
    "application/json" = "nvim-terminal.desktop";
    "text/html" = "zen-beta.desktop";
    "x-scheme-handler/http" = "zen-beta.desktop";
    "x-scheme-handler/https" = "zen-beta.desktop";
  };

  # Containers: Docker daemon and its module-provided command-line tools.
  virtualisation.docker.enable = true;

  # Housekeeping: empty user trash entries older than 20 days, once per day.
  systemd.user.services.trash-cleanup = {
    description = "Remove trash entries older than 20 days";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.trash-cli}/bin/trash-empty 20";
    };
  };
  systemd.user.timers.trash-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };

  # Nix: reproducible inputs, bounded builds on this 8 GB laptop, and store deduplication.
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = 2;
      cores = 2;
    };
    optimise.automatic = true;
  };
  nixpkgs.config.allowUnfree = true;

  # Compatibility: keep the original installation version when upgrading NixOS.
  system.stateVersion = "26.05";
}
