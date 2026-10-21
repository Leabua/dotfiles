{ pkgs, inputs, ... }:

let
  penelope = inputs.penelope;
  staleHash = "sha256-gO5QoJuV6Yo3f0YyHg+uHBk2caV+B6/LpjNThGlkbN8=";
  # Correct beta's stale Bun cache hash until upstream refreshes it.
  needsHashFix = pkgs.lib.hasInfix staleHash (builtins.readFile "${penelope}/flake.nix");
  source = pkgs.applyPatches {
    name = "penelope-source";
    src = penelope;
    postPatch = ''
      substituteInPlace flake.nix \
        --replace-fail '${staleHash}' 'sha256-eJxwfxvYsoPOktL2vg+mQNKCoT6SPQe6xUqxkD/knjM='
    '';
  };
  desktopFlake =
    if needsHashFix then
      (import "${source}/flake.nix").outputs {
        self = penelope // {
          outPath = source;
        };
        nixpkgs = penelope.inputs.nixpkgs;
      }
    else
      penelope;
in
{
  # Desktop client: use the hosted backend, with no local backend service.
  environment.systemPackages = [
    desktopFlake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
