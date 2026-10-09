{ pkgs, ... }:

{
  # Steam: client, network features, and declarative Proton-GE compatibility.
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # Performance: CPU governor and process priority requested through gamemoderun.
  programs.gamemode.enable = true;

  # Gamescope: Vulkan compositor for upscaling and frame pacing on the Intel GPU.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Controllers: udev rules and permissions for gamepads and VR devices.
  hardware.steam-hardware.enable = true;

  # Utilities: performance overlay and optional manual Proton version management.
  environment.systemPackages = with pkgs; [
    mangohud # FPS / frame-time overlay, works with gamescope and gamemode
    protonup-qt # optionally manage extra Proton-GE versions imperatively
  ];
}
