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
    tag = "release/shs-${finalAttrs.version}";
    sha256 = "sha256-ckz8KYlhR9QSZPKf3IuJuUdZ/v4Kqtj/uPfshgGOYQw=";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out
    cp -r include $out
    cp -r share $out
  '';

  meta = {
    description = "Hardware definitions and C headers for usage with Cassini/Slingshot high speed network";
    homepage = "https://github.com/HewlettPackard/shs-cassini-headers";
    license = with lib.licenses; [
      bsd2
    ];
    platforms = lib.platforms.linux;
  };

})
