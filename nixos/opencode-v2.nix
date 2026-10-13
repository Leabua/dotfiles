{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchurl,
  glibc,
}:

let
  version = "2.0.28";
  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha512-HdgQ2c9FrER88w3Alm/UGdzU55lCc0FXxSm+VNMXUz+Yyv03uLc0Z+PxSnEBysmYNKcFvcnxdT7e0xGPoytrNg==";
  };
in
stdenv.mkDerivation {
  pname = "opencode-v2";
  inherit version src;

  sourceRoot = "package";
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ glibc ];
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode "$out/bin/opencode"
    ln -s opencode "$out/bin/opencode2"
    runHook postInstall
  '';

  meta = {
    description = "OpenCode 2 CLI for x86_64 Linux";
    homepage = "https://opencode.ai/v2";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
