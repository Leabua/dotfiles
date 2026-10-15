{ pkgs, inputs, ... }:

{
  # Desktop client: use the hosted backend, with no local backend service.
  environment.systemPackages = [
    inputs.penelope.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
