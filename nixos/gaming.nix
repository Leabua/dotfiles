{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # CPU governor / priority tweaks requested by games via gamemoderun
  programs.gamemode.enable = true;

  # Vulkan micro-compositor: upscaling + vsync control.
  # Useful on the UHD 620 iGPU; also powers the "gamescope session" option.
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # udev rules + permissions for Steam controllers, PS/Xbox/Nintendo pads, VR
  hardware.steam-hardware.enable = true;

  environment.systemPackages = with pkgs; [
    mangohud # FPS / frame-time overlay, works with gamescope and gamemode
    protonup-qt # optionally manage extra Proton-GE versions imperatively
  ];
}
