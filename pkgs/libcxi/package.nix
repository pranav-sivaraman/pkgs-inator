{
  lib,
  stdenv,
  testers,
  fetchFromGitHub,
  autoreconfHook,
  libtool,
  pkg-config,
  validatePkgConfig,
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
  plantuml,
  systemdMinimal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcxi";
  version = "14.0.1";

  __structuredAttrs = true;
  strictDeps = true;

  enableParallelBuilding = true;
  enableParallelChecking = true;
  enableParallelInstalling = true;

  src = fetchFromGitHub {
    owner = "HewlettPackard";
    repo = "shs-libcxi";
    tag = "release/shs-${finalAttrs.version}";
    sha256 = "sha256-cJbbIr6VOkC4U8lABFS0LBJk10i9FtRmdHXJBM3/nw0=";
  };

  postPatch = ''
    patchShebangs --build utils/cxi_dump_csrs.py
    substituteInPlace utils/cxi_dump_csrs.py \
      --replace-fail /usr/share/cassini-headers/csr_defs.json ${cassini-headers}/share/cassini-headers/csr_defs.json
  '';

  nativeBuildInputs = [
    autoreconfHook
    libtool
    pkg-config
    validatePkgConfig
    pandoc
    python3
    plantuml
  ];

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
    systemdMinimal
  ];

  configureFlags = [
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-udevrulesdir=${placeholder "out"}/lib/udev/rules.d"
  ];

  outputs = [
    "out"
    "lib"
    "dev"
    "bin"
    "man"
  ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
    versionCheck = false;
  };

  meta = {
    description = "The CXI library provides interfaces which interact directly with CXI drivers";
    homepage = "https://github.com/HewlettPackard/shs-libcxi";
    license = with lib.licenses; [
      bsd2
    ];
    platforms = lib.platforms.linux;
    pkgConfigModules = [ "libcxi" ];
  };
})
