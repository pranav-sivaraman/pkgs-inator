{
  lib,
  config,
  stdenv,
  fetchurl,
  libfabric,
  hwloc,
  cudaPackages,
  cudaSupport ? config.cudaSupport,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "aws-ofi-nccl";
  version = "1.20.0";

  src = fetchurl {
    url = "https://github.com/aws/aws-ofi-nccl/releases/download/v${finalAttrs.version}/aws-ofi-nccl-${finalAttrs.version}.tar.gz";
    hash = "sha256-L3I8SvX8H6Sz79ICWCKzGzrww0D3WjEqN+kyt3uCQlA=";
  };

  buildInputs = [
    libfabric
    hwloc
  ]
  ++ lib.optionals cudaSupport [ cudaPackages.cuda_cudart ];

  configureFlags = [
    (lib.withFeatureAs true "libfabric" libfabric)
    (lib.withFeatureAs true "hwloc" hwloc)
    (lib.withFeatureAs cudaSupport "cuda" cudaPackages.cuda_cudart)
  ];

  meta = {
    description = "Plugin which lets EC2 developers use libfabric as a network provider while running NCCL applications";
    homepage = "https://github.com/aws/aws-ofi-nccl";
    changelog = "https://github.com/aws/aws-ofi-nccl/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
  };
})
