{
  lib,
  stdenv,
  fetchurl,
  libfabric,
  rdma-core,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fabtests";
  version = "2.6.0";

  __structuredAttrs = true;
  strictDeps = true;

  enableParallelBuilding = true;
  enableParallelChecking = true;
  enableParallelInstalling = true;

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v${finalAttrs.version}/fabtests-${finalAttrs.version}.tar.bz2";
    hash = "sha256-ed2rEpD81ix2c1znwlonfLMi3pHV4baWtuAaiCTGK30=";
  };

  buildInputs = [
    libfabric
    rdma-core
  ];

  outputs = [
    "out"
    "man"
  ];

  meta = {
    description = "Fabtests test suite for libfabric";
    homepage = "https://ofiwg.github.io/libfabric";
    license = with lib.licenses; [
      bsd2
      gpl2Only
    ];
    platforms = lib.platforms.unix;
  };
})
