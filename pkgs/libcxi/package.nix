{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  validatePkgConfig,
  testers,
  pkg-config,
  libconfig,
  libuv,
  fuse,
  libyaml,
  libnl,
  numactl,
  lm_sensors,
  pandoc,
  python3,
  cassini-headers,
  cxi-driver,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcxi";
  version = "14.0.1";

  src = fetchFromGitHub {
    owner = "HewlettPackard";
    repo = "shs-libcxi";
    rev = "release/shs-${finalAttrs.version}";
    hash = "sha256-cJbbIr6VOkC4U8lABFS0LBJk10i9FtRmdHXJBM3/nw0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    pandoc
    python3
    validatePkgConfig
  ];

  postPatch = ''
    patchShebangs --build utils/cxi_dump_csrs.py
    substituteInPlace utils/cxi_dump_csrs.py \
      --replace-fail /usr/share/cassini-headers/csr_defs.json \
                     ${cassini-headers}/share/cassini-headers/csr_defs.json
  '';

  buildInputs = [
    libconfig
    libuv
    fuse
    libyaml
    libnl
    numactl
    lm_sensors
    cassini-headers
    cxi-driver
  ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = false;
  };

  meta = {
    description = "The CXI library provides interfaces which interact directly with CXI drivers";
    homepage = "https://github.com/HewlettPackard/shs-libcxi";
    license = with lib.licenses; [
      lgpl21Plus
      bsd3
    ];
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux;
    pkgConfigModules = [ "libcxi" ];
  };
})
