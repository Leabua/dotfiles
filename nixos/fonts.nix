{ pkgs, inputs, ... }:

let
  appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};

  # hyprlock's clock face. Not packaged on its own in nixpkgs, and
  # google-fonts.override would pull the whole repo.
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
  # Apple's San Francisco family, hyprlock's clock, monospace / Nerd Font faces,
  # and Roboto Flex (niriBar's Material 3 face; its width axis draws the tall
  # stacked clock).
  fonts.packages = with pkgs; [
    appleFonts.sf-pro
    appleFonts.sf-mono
    pixelify-sans
    maple-mono.NF
    # nerd-fonts.iosevka
    # roboto-flex
  ];
}
