{ pkgs, inputs, ... }:

let
  appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};

  # hyprlock's clock face; not packaged on its own in nixpkgs, and google-fonts.override pulls the whole repo
  pixelify-sans = pkgs.stdenvNoCC.mkDerivation {
    pname = "pixelify-sans";
    version = "2024-google-fonts-9ce5017";
    src = pkgs.fetchurl {
      name = "PixelifySans.ttf";
      url = "https://raw.githubusercontent.com/google/fonts/9ce5017522020232f525003b39971ddb67e33243/ofl/pixelifysans/PixelifySans%5Bwght%5D.ttf";
      hash = "sha256-m6hs0BCk3jCdJjzv+OgEQJLJ2379qGliDLn/HEOJ6KU=";
    };
    dontUnpack = true;
    installPhase = "install -Dm644 $src $out/share/fonts/truetype/PixelifySans.ttf";
    meta.license = pkgs.lib.licenses.ofl;
  };
in
{
  # Fonts: regular monospace faces, Nerd Font variants, Apple's San Francisco family, and the lock-screen clock.
  fonts.packages = with pkgs; [
    pixelify-sans
    maple-mono.NF
    nerd-fonts.iosevka
    appleFonts.sf-pro
    appleFonts.sf-mono
  ];
}
