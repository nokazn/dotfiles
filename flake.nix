{
  description = "dotfiles of nokazn";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    inputs@{ nixpkgs
    , nixpkgs-darwin
    , nix-darwin
    , home-manager
    , devshell
    , flake-utils
    , ...
    }:
    let
      user = {
        name = "nokazn";
      };
      nix = {
        version = "23.11";
      };
      homeManagerConfigurations = (home: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user.name} = home;
        };
      });
    in
    {
      # For user environments
      # - home-manager switch .#${USER}
      # - home-manager switch .#wsl
      homeConfigurations = nixpkgs.lib.listToAttrs (builtins.map
        (meta: {
          name = meta.name;
          value = home-manager.lib.homeManagerConfiguration {
            pkgs = nixpkgs.legacyPackages.x86_64-linux;
            modules = [
              ./home/linux.nix
            ];
            extraSpecialArgs = {
              inherit user nix;
              meta = meta.value;
            };
          };
        })
        [
          { name = user.name; value = { isWsl = false; }; }
          { name = "wsl"; value = { isWsl = true; }; }
        ]);

      # For darwin
      # - darwin-rebuild switch .#${system}
      darwinConfigurations = nixpkgs.lib.listToAttrs (builtins.map
        (system: {
          name = system;
          value = nix-darwin.lib.darwinSystem rec {
            inherit system;
            pkgs = nixpkgs-darwin.legacyPackages.${system};
            modules = [
              ./hosts/darwin
              home-manager.darwinModules.home-manager
              (homeManagerConfigurations (import ./home/darwin.nix {
                inherit pkgs user nix;
                lib = pkgs.lib;
                meta = { isWsl = false; };
              }))
            ];
            specialArgs = { inherit user nix; };
          };
          specialArgs = { inherit user nix; };
        }) [ "aarch64-darwin" "x86_64-darwin" ]);

    } // (flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              gnumake
              shellcheck
              shfmt
              nixpkgs-fmt
              pre-commit
              treefmt
            ];
          };
      }));

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    auto-optimise-store = true;
    eval-cache = true;
  };
}
