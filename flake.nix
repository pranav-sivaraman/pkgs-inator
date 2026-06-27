{
  description = "Description for the project";

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
        { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              cudaSupport = true;
            };
            overlays = [
              (final: prev: {
                cudaPackages = prev.cudaPackages_13;
              })

              (
                final: prev:
                prev.lib.filesystem.packagesFromDirectoryRecursive {
                  callPackage = final.callPackage;
                  directory = ./pkgs;
                }
              )

              (final: prev: {
                libfabric = prev.libfabric.override {
                  enableCxi = true;
                };
              })
            ];
          };

          localPackageNames = builtins.attrNames (
            pkgs.lib.filesystem.packagesFromDirectoryRecursive {
              callPackage = pkgs.callPackage;
              directory = ./pkgs;
            }
          );
        in
        {
          packages = pkgs.lib.genAttrs localPackageNames (name: pkgs.${name});
        };
    };
}
