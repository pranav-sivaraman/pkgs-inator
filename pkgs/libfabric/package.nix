{
  lib,
  config,
  stdenv,
  fetchurl,
  testers,
  pkg-config,
  validatePkgConfig,
  providers ? {
    cxi = stdenv.hostPlatform.isLinux;
    sockets = stdenv.hostPlatform.isUnix;
    tcp = stdenv.hostPlatform.isUnix;
    udp = stdenv.hostPlatform.isUnix;
  },
  features ? {
    cuda = config.cudaSupport;
    gdrcopy = config.cudaSupport;
    rocr = config.rocmSupport;
  },
  libcxi,
  cassini-headers,
  cxi-driver,
  curlMinimal,
  json_c,
  cudaPackages,
  rocmPackages,
}:

let
  providerDeps = {
    cxi = [
      libcxi
      cassini-headers
      cxi-driver
      curlMinimal
      json_c
    ];
  };

  featureDeps = {
    cuda = [
      cudaPackages.cuda_cudart
      cudaPackages.cuda_nvml_dev
    ];
    gdrcopy = [ cudaPackages.gdrcopy ];
    rocr = [ rocmPackages.rocm-runtime ];
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "libfabric";
  version = "2.6.0";

  __structuredAttrs = true;
  strictDeps = true;

  enableParallelBuilding = true;
  enableParallelChecking = true;
  enableParallelInstalling = true;

  src = fetchurl {
    url = "https://github.com/ofiwg/libfabric/releases/download/v${finalAttrs.version}/libfabric-${finalAttrs.version}.tar.bz2";
    hash = "sha256-HuKrbrFkYsD+eoNvnfUrjxIwnf7j83dKqTqG9SGo6LE=";
  };

  dontDisableStatic = providers.cxi;

  nativeBuildInputs = [
    pkg-config
    validatePkgConfig
  ];

  buildInputs =
    lib.concatLists (
      lib.mapAttrsToList (
        provider: enabled: lib.optionals enabled (providerDeps.${provider} or [ ])
      ) providers
    )
    ++ lib.concatLists (
      lib.mapAttrsToList (
        feature: enabled: lib.optionals enabled (featureDeps.${feature} or [ ])
      ) features
    );

  env.NIX_LDFLAGS = lib.optionalString features.cuda ''
    -L${cudaPackages.cuda_cudart}/lib/stubs
    -L${lib.getOutput "stubs" cudaPackages.cuda_nvml_dev}/lib/stubs
  '';

  configureFlags =
    lib.mapAttrsToList (provider: enabled: lib.enableFeature enabled provider) providers
    ++ lib.mapAttrsToList (feature: enabled: lib.withFeature enabled feature) features;

  outputs = [
    "out"
    "lib"
    "dev"
    "bin"
    "man"
  ];

  passthru = {
    providerSets.none = lib.genAttrs (lib.attrNames providers) (_: false);

    tests.pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
      versionCheck = true;
    };
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
