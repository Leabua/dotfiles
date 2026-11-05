{ pkgs, inputs, ... }:

{
  # Penelope Unstable: the main branch with its unfinished features, on its own
  # local backend. `upgrade` updates it along with every other input.
  environment.systemPackages = [
    inputs.penelope.packages.${pkgs.stdenv.hostPlatform.system}.unstable
  ];
}
