{ pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./packages.nix
    ./dev.nix
    ./fonts.nix
    # ./gaming.nix
    inputs.blip.nixosModules.default
  ];

  # Overlays: local packages, flake packages, and temporary upstream fixes.
  nixpkgs.overlays = [
    (final: prev: {
      opencodeV2 = final.callPackage ./opencode-v2.nix { };
      t3code = inputs.t3code.packages.${final.stdenv.hostPlatform.system}.t3-code-nightly;

      # Fixes nixpkgs' wrong pnpm dependency hash for 6.0.2. Switches itself
      # off as soon as nixpkgs ships a different version or hash.
      typescript-language-server = prev.typescript-language-server.overrideAttrs (
        oldAttrs:
        prev.lib.optionalAttrs
          (
            oldAttrs.version == "6.0.2"
            && oldAttrs.pnpmDeps.outputHash == "sha256-MUSxDMlbG21KSesGdEvqa2kEpuVfLlXRUX1qV/FGsSo="
          )
          {
            pnpmDeps = oldAttrs.pnpmDeps.overrideAttrs {
              outputHash = "sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=";
            };
          }
      );
    })
  ];
  nixpkgs.config.allowUnfree = true;

  # Nix: flakes, bounded builds for this 8 GB laptop, and store deduplication.
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
    # Builds, fetches and store writes yield the CPU and disk to the desktop.
    # Best-effort/7 rather than "idle" I/O, which can starve the daemon while it
    # holds filesystem locks and stall everything behind it.
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "best-effort";
    daemonIOSchedPriority = 7;
  };

  # Disk responsiveness: the 128 GB SATA SSD is slow at sustained writes, and
  # one big write burst (nix store, git, builds) used to freeze the whole desktop.
  # BFQ schedules disk access per process so interactive apps stay responsive and
  # honours the nix-daemon's low I/O priority.
  boot.kernelModules = [ "bfq" ];
  services.udev.extraRules = ''
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="bfq"
  '';
  # Flush dirty pages early, in small batches. By default up to ~1.5 GB (20% of
  # RAM) can pile up and then hit the disk at once, blocking every fsync on it.
  boot.kernel.sysctl = {
    "vm.dirty_bytes" = 268435456; # 256 MiB
    "vm.dirty_background_bytes" = 67108864; # 64 MiB
  };
  # Skip access-time writes on every file read.
  fileSystems."/".options = [ "noatime" ];

  # Boot: systemd-boot with a Memtest86+ entry, and compressed RAM swap.
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.memtest86.enable = true;
    efi.canTouchEfiVariables = true;
  };
  # Quick RAM pattern test at every boot (a few seconds). Bad cells are logged
  # as "bad mem addr" in `journalctl -k -b` and kept unused.
  boot.kernelParams = [ "memtest=4" ];
  zramSwap.enable = true;

  # Hardware quirks for the HP Pavilion 15-cs2xxx.
  boot.extraModprobeConfig = ''
    # The RTL8821CE can hang in deep power save or PCIe link power saving.
    options rtw88_core disable_lps_deep=y
    options rtw88_pci disable_aspm=y

    # Use Mic3 (NID 0x1b) for the ALC295 speaker mute LED.
    options snd_hda_intel model=hp-mute-led-mic3
  '';

  # Storage: optional data drive; boot continues when it is absent.
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-uuid/4fc12482-bbb3-4ced-a896-2b5f560c9f6b";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=5s"
    ];
  };

  # Networking: NetworkManager, SSH, and local dev server ports (Vite, Tauri).
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [
      5173
      1420
    ];
  };
  services.openssh.enable = true;

  # Locale and input: local time and system-wide Caps Lock / Escape swap.
  time.timeZone = "Africa/Johannesburg";
  services.xserver.xkb.options = "caps:swapescape";
  console.useXkbConfig = true;
  services.libinput.enable = true;

  # User and shell: zsh with Powerlevel10k; plugins are sourced by ~/.zshrc.
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
  programs.bash = {
    enable = true;
    blesh.enable = false;
  };
  programs.zsh = {
    enable = true;
    # ~/.zshrc runs compinit and sets the prompt; skip the system copies.
    enableGlobalCompInit = false;
    promptInit = "";
  };
  environment.pathsToLink = [ "/share/zsh-syntax-highlighting" ];
  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = false;
  };

  # Programs: Blip, and nix-ld for running unpatched binaries.
  programs.blip.enable = true;
  programs.nix-ld.enable = true;

  # Desktop session: Ly greeter, Niri and Hyprland, and the polkit agent.
  services.displayManager.ly.enable = true;
  programs.niri.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    # Matches the cached nixpkgs build; without it Hyprland compiles from source.
    withUWSM = true;
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

  # Graphics: Intel video acceleration, including 32-bit applications.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  # Power and Bluetooth: backends for the Quickshell widgets and power menu.
  services.upower.enable = true;
  # At critical battery, power off cleanly (like Arch did) instead of the default
  # HybridSleep, which suspends at 2% and leaves the laptop stuck on the lock screen.
  services.upower.criticalPowerAction = "PowerOff";
  services.power-profiles-daemon.enable = true;
  hardware.bluetooth.enable = true;
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # Desktop integration: keyring, removable drives, and phone mounting.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;

  # Thunar: xfconf stores its preferences; tumbler draws thumbnails.
  programs.xfconf.enable = true;
  services.tumbler.enable = true;

  # Appearance and defaults: dark GTK/Qt themes and preferred applications.
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
          icon-theme = "Quickshell";
        };
      }
    ];
  };

  # Portals and file associations.
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

  # # Containers: the Docker module also installs the docker CLI.
  # virtualisation.docker.enable = true;

  # Housekeeping: daily removal of trash entries older than 20 days.
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

  # Keep at the original install version; it is not the NixOS version.
  system.stateVersion = "26.05";
}
