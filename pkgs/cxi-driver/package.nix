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
    rev = "release/shs-${finalAttrs.version}";
    hash = "sha256-B54LPGjHogb8n7CsauTVXkEPxQ2ksXHtadLKeuV/vko=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/include
    cp -r include/. $out/include/

    runHook postInstall
  '';

  meta = {
    description = "Linux driver headers for Cray/HPE Cassini Slingshot interconnect";
    homepage = "https://github.com/HewlettPackard/shs-cxi-driver";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
})
