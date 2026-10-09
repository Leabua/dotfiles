{
  lib,
  runCommand,
  symlinkJoin,
  makeWrapper,
  codex,
  ripgrep,
  bubblewrap,
  stdenv,
  ...
}:

# Platform: this package layout matches the laptop's Linux GNU release target.
assert stdenv.hostPlatform.system == "x86_64-linux";

let
  # Metadata: use the manifest schema consumed by Codex's daemon installer.
  manifest = builtins.toJSON {
    layoutVersion = 1;
    version = codex.version;
    target = "x86_64-unknown-linux-gnu";
    variant = "codex";
    entrypoint = "bin/codex";
    resourcesDir = "codex-resources";
    pathDir = "codex-path";
  };
  # Packaging: reuse Nixpkgs binaries without rebuilding Rust or adding a flake input.
  package =
    runCommand "codex-packaged-${codex.version}"
      {
        inherit (codex) version;
        meta = codex.meta;
      }
      ''
        mkdir -p "$out/bin" "$out/codex-path" "$out/codex-resources"

        # Entrypoint: copy the real executable so daemon identity checks still match.
        cp ${codex}/bin/.codex-wrapped "$out/bin/codex"
        cp ${codex}/bin/codex-code-mode-host "$out/bin/codex-code-mode-host"

        # Helpers: copies stay inside the package, as required by daemon validation.
        cp ${ripgrep}/bin/rg "$out/codex-path/rg"
        cp ${bubblewrap}/bin/bwrap "$out/codex-resources/bwrap"
        printf '%s\n' ${lib.escapeShellArg manifest} > "$out/codex-package.json"

        # Completions: retain the shell integration provided by Nixpkgs.
        cp -r ${codex}/share "$out/share"
      '';
in
# Startup: enable the shared daemon whenever the system Codex command is used.
symlinkJoin {
  name = "codex-${codex.version}";
  inherit (codex) version meta;
  paths = [ package ];
  nativeBuildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram "$out/bin/codex" --add-flags "--enable daemon_auto_start"
  '';
}
