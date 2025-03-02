{
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
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.devenv-up = self.devShells.${system}.default.config.procfileScript;
      packages.devenv-test = self.devShells.${system}.default.config.test;

      devShells.default = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          {
            languages.dotnet.enable = true;

            pre-commit.hooks = {
              alejandra.enable = true;
              commitizen.enable = true;
              markdownlint.enable = true;
            };
          }
        ];
      };
    });
}
