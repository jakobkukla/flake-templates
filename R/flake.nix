{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
  };

  outputs = {
    self,
    nixpkgs,
    devenv,
    systems,
    ...
  } @ inputs: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    devShells =
      forEachSystem
      (system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in let
        r_pkgs = with pkgs; [
          rPackages.tidyverse
          rPackages.pracma
          rPackages.infer
          rPackages.ggfortify

          ### markdown
          rPackages.rmarkdown
          rPackages.markdown
        ];

        rstudio-wrapper = pkgs.rstudioWrapper.override {packages = r_pkgs;};
      in {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            {
              # https://devenv.sh/reference/options/
              packages = with pkgs; [
                rstudio-wrapper
                pandoc
              ];

              languages.r.enable = true;
              languages.r.package = pkgs.rWrapper.override {
                packages = r_pkgs;
              };
            }
          ];
        };
      });
  };
}
