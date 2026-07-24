{
  description = "Behold my pkgs-inator!";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
              (final: prev: {
                cudaPackages = final.cudaPackages_13;
              })
              inputs.self.overlays.default
            ];
            config = {
              rocmSupport = true;
              allowUnfree = true;
            };
          };
        in
        {
          packages.default = pkgs.aws-ofi-nccl;
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
