{
  lib,
  stdenv,
  fetchurl,
  validatePkgConfig,
  testers,
  pkg-config,
  libcxi,
  cassini-headers,
  cxi-driver,
  json_c,
  curl,
  enableCxi ? false,
  enableEfa ? false,
  enableLnx ? false,
  enableLpp ? false,
  enableMrail ? false,
  enableOpx ? false,
  enablePsm2 ? false,
  enablePsm3 ? false,
  enableRxd ? false,
  enableRxm ? false,
  enableShm ? false,
  enableSockets ? true,
  enableTcp ? true,
  enableUcx ? false,
  enableUdp ? true,
  enableUsnic ? false,
  enableVerbs ? false,
}:

assert lib.assertMsg (
  !enableCxi || stdenv.hostPlatform.isLinux
) "libfabric: CXI support is only available on Linux";

stdenv.mkDerivation (finalAttrs: {
  pname = "libfabric";
  version = "2.6.0";

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v${finalAttrs.version}/libfabric-${finalAttrs.version}.tar.bz2";
    hash = "sha256-HuKrbrFkYsD+eoNvnfUrjxIwnf7j83dKqTqG9SGo6LE=";
  };

  dontDisableStatic = true;

  nativeBuildInputs = [
    pkg-config
    validatePkgConfig
  ];

  buildInputs = lib.optionals enableCxi [
    libcxi
    cassini-headers
    cxi-driver
    json_c
    curl
  ];

  enableParallelBuilding = true;
  enableParallelInstalling = true;
  enableParallelChecking = true;

  postInstall = ''
    rm -f $out/lib/*.la
  '';

  configureFlags = [
    (lib.enableFeatureAs enableCxi "cxi" libcxi)
    (lib.withFeatureAs enableCxi "cassini-headers" cassini-headers)
    (lib.withFeatureAs enableCxi "curl" (lib.getDev curl))
    (lib.withFeatureAs enableCxi "cxi-uapi-headers" cxi-driver)
    (lib.withFeatureAs enableCxi "json-c" (lib.getDev json_c))
    (lib.enableFeature enableEfa "efa")
    (lib.enableFeature enableLnx "lnx")
    (lib.enableFeature enableLpp "lpp")
    (lib.enableFeature enableMrail "mrail")
    (lib.enableFeature enableOpx "opx")
    (lib.enableFeature enablePsm2 "psm2")
    (lib.enableFeature enablePsm3 "psm3")
    (lib.enableFeature enableRxd "rxd")
    (lib.enableFeature enableRxm "rxm")
    (lib.enableFeature enableShm "shm")
    (lib.enableFeature enableSockets "sockets")
    (lib.enableFeature enableTcp "tcp")
    (lib.enableFeature enableUcx "ucx")
    (lib.enableFeature enableUdp "udp")
    (lib.enableFeature enableUsnic "usnic")
    (lib.enableFeature enableVerbs "verbs")
  ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = true;
  };

  meta = {
    description = "Open Fabrics Interfaces library";
    homepage = "https://ofiwg.github.io/libfabric";
    license = with lib.licenses; [
      bsd2
      gpl2Only
    ];
    platforms = lib.platforms.unix;
    pkgConfigModules = [ "libfabric" ];
  };
})
