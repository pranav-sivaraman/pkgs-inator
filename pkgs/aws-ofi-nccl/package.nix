{
  lib,
  stdenv,
  fetchurl,
  libfabric,
  config,
  hwloc,
  cudaSupport ? config.cudaSupport,
  cudaPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aws-ofi-nccl";
  version = "1.20.0";

  __structuredAttrs = true;
  strictDeps = true;

  enableParallelBuilding = true;
  enableParallelChecking = true;
  enableParallelInstalling = true;

  src = fetchurl {
    url = "https://github.com/aws/aws-ofi-nccl/releases/download/v${finalAttrs.version}/aws-ofi-nccl-${finalAttrs.version}.tar.gz";
    hash = "sha256-L3I8SvX8H6Sz79ICWCKzGzrww0D3WjEqN+kyt3uCQlA=";
  };

  buildInputs = [
    libfabric
    hwloc
  ]
  ++ lib.optionals cudaSupport (
    with cudaPackages;
    [
      cuda_cudart
      gdrcopy
    ]
  );

  configureFlags = [
    (lib.withFeatureAs cudaSupport "cuda" cudaPackages.cuda_cudart) # needed for tests to build properly
  ];

  meta = {
    description = "AWS Open Fabrics Interfaces ofi-NCCL plugin";
    homepage = "https://github.com/aws/aws-ofi-nccl";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
  };
})
