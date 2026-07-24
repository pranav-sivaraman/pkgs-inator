{
  description = "Behold my pkgs-inator!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0.1";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        {
          system,
          ...
        }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlays.default
            ];
            config = {
              allowUnfree = true;
            };
          };
        in
        {
          packages.default = pkgs.libfabric;
        };

      flake = {
        overlays.default =
          final: prev:
          prev.lib.filesystem.packagesFromDirectoryRecursive {
            inherit (final) callPackage;
            directory = ./pkgs;
          };
      };
    };
}
