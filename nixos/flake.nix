{
  description = "Hyprland on Nixos";
  # Inputs: pin dependencies through flake.lock and share one nixpkgs revision.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    helium = {
      url = "github:schembriaiden/helium-browser-nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    herdr = {
      url = "github:herdrdev/herdr/v0.8.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    clocktui = {
      url = "github:Leabua/ClockTUI";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    blip = {
      url = "github:blip-net/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  # Outputs: build the host using the platform declared in its hardware module.
  outputs =
    { nixpkgs, ... }@inputs:
    {
      # Formatting: use the same Nix formatter as the development toolset.
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt;

      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
        ];
      };
    };
}
