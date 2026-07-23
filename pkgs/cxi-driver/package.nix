{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cxi-driver";
  version = "14.0.1";

  src = fetchFromGitHub {
    owner = "HewlettPackard";
    repo = "shs-cxi-driver";
    tag = "release/shs-${finalAttrs.version}";
    sha256 = "sha256-B54LPGjHogb8n7CsauTVXkEPxQ2ksXHtadLKeuV/vko=";
  };

  phases = [
    "unpackPhase"
    "installPhase"
  ];

  installPhase = ''
    mkdir -p $out
    cp -r include $out
  '';

  meta = {
    description = "The core driver for Cassini 1 and 2, and its Ethernet driver";
    homepage = "https://github.com/HewlettPackard/shs-cxi-driver";
    license = with lib.licenses; [
      lgpl21Plus
    ];
    platforms = lib.platforms.linux;
  };
})
