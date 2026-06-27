{
  lib,
  fetchFromGitHub,
  python3Packages,
  rustPlatform,
  cargo,
  rustc,
  symlinkJoin,
  cudaPackages,
  libfabric,
  rdma-core,
}:

python3Packages.buildPythonPackage rec {
  pname = "pplx-garden";
  version = "0.0.0+unstable-2026-06-27";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "perplexityai";
    repo = "pplx-garden";
    rev = "244600375fe93f136103e0e44a1618cf332a03dc";
    hash = "sha256-GHVZxL8KrC5MHvLBf5WfTKDIkz4ufXUygESgz8MwHdw=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit src;
    hash = "sha256-3/0iZoH5tv2a1L+1sANBvyjq/ojwEFYXk+k3DxTpXl8=";
  };

  cudaHome = symlinkJoin {
    name = "cuda-home";
    paths = [
      cudaPackages.cuda_cudart
      cudaPackages.cuda_crt
      (lib.getInclude cudaPackages.cuda_profiler_api)
    ];
  };

  env = {
    CUDA_HOME = cudaHome;
    LIBFABRIC_HOME = libfabric;
    LIBIBVERBS_HOME = rdma-core;
    GDRAPI_HOME = cudaPackages.gdrcopy;
  };

  nativeBuildInputs = with python3Packages; [
    setuptools
    setuptools-scm
    setuptools-rust
    rustPlatform.cargoSetupHook
    rustPlatform.bindgenHook
    cargo
    rustc
    torch-bin
  ];

  propagatedBuildInputs = with python3Packages; [
    torch-bin
    numpy
  ];

  meta = {
    description = "Perplexity AI open source garden for inference technology";
    homepage = "https://github.com/perplexityai/pplx-garden";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
