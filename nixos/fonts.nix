{ pkgs, inputs, ... }:

let
  appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # Fonts: regular monospace faces, Nerd Font variants, and Apple's San Francisco family.
  fonts.packages = with pkgs; [
    departure-mono
    maple-mono.NF
    nerd-fonts.departure-mono
    nerd-fonts.iosevka
    appleFonts.sf-pro
    appleFonts.sf-mono
  ];
}
