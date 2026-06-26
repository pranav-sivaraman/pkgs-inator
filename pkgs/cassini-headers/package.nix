{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cassini-headers";
  version = "14.0.1";

  src = fetchFromGitHub {
    owner = "HewlettPackard";
    repo = "shs-cassini-headers";
    rev = "release/shs-${finalAttrs.version}";
    hash = "sha256-ckz8KYlhR9QSZPKf3IuJuUdZ/v4Kqtj/uPfshgGOYQw=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r include share $out/

    runHook postInstall
  '';

  meta = {
    description = "Cassini hardware interface headers";
    homepage = "https://github.com/HewlettPackard/shs-cassini-headers";
    license = with lib.licenses; [
      gpl2Only
      bsd2
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
})
