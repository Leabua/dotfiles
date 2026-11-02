{ pkgs, inputs, ... }:

{
  # Penelope Unstable: the main branch with its unfinished features, on its own
  # local backend. Update with `nix flake update penelope`, then rebuild.
  environment.systemPackages = [
    inputs.penelope.packages.${pkgs.stdenv.hostPlatform.system}.unstable
  ];
}
