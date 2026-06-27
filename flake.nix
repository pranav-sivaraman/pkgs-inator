{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake.overlays = {
        packages =
          final: prev:
          prev.lib.filesystem.packagesFromDirectoryRecursive {
            callPackage = final.callPackage;
            directory = ./pkgs;
          };

        overrides = final: prev: {
          cudaPackages = prev.cudaPackages_13_1;
          libfabric = prev.libfabric.override {
            enableCxi = true;
          };
        };

        default = inputs.nixpkgs.lib.composeManyExtensions [
          self.overlays.packages
          self.overlays.overrides
        ];
      };

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
              self.overlays.default
            ];
          };

          image = pkgs.dockerTools.buildLayeredImage {
            name = "pkgs-inator";
            tag = "latest";
            contents = [
              pkgs.aws-ofi-nccl
              pkgs.pplx-garden
            ];
          };
        in
        {
          packages.default = image;
        };
    };
}
