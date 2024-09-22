{
  description = "rtnlmgrn";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    flake-root.url = "github:srid/flake-root";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    flake-parts,
    devshell,
    treefmt-nix,
    flake-root,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        devshell.flakeModule
        treefmt-nix.flakeModule
        flake-root.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        packages.default = config.packages.website;
        packages.website = pkgs.stdenv.mkDerivation rec {
          pname = "static-website";
          version = "2024-09-22";
          src = ./.;
          nativeBuildInputs = [pkgs.zola];
          buildPhase = "zola build -o $out";
        };

        devshells.default = {
          name = "rtnlmgrn";
          commands = [
            {
              name = "serve";
              category = "zola";
              help = "Serve zola site";
              command = "zola serve";
            }
            {
              name = "build";
              category = "zola";
              help = "Build zola site";
              command = "zola build";
            }
            {
              name = "check";
              category = "zola";
              help = "Check links";
              command = "zola check";
            }
          ];
          packages = with pkgs; [
            zola
          ];
        };
        treefmt = {
          inherit (config.flake-root) projectRootFile;
          package = pkgs.treefmt;
          programs = {
            alejandra.enable = true;
            prettier.enable = true;
          };
          settings.global.excludes = [
            ".envrc"
            ".gitignore"
            ".direnv/**"
          ];
        };
      };
    };
}
