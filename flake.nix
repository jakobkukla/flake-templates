{
  description = "A collection of flake templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devenv,
    ...
  } @ inputs:
    {
      templates = {
        rust = {
          path = ./rust;
          description = "A basic rust template";
        };

        devenv = {
          path = ./devenv;
          description = "A basic devenv.sh template";
        };

        default = self.templates.devenv;
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            pre-commit.hooks = {
              alejandra.enable = true;
              markdownlint.enable = true;
            };
          }
        ];
      };
    });
}
