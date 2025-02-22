{
  description = "dotfiles of nokazn";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # In nixpkgs-unstale all packages are built for supported platforms including darwin
    # https://discourse.nixos.org/t/differences-between-nix-channels/13998/5
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs =
    { nixpkgs
    , nixpkgs-darwin
    , nix-darwin
    , home-manager
    , flake-utils
    , ...
    }:
    let
      USER = "nokazn";
      # username in GitHub Actions
      CI_USER = "runner";
      # this line is replaced by the real user name as fallback

      HOST = "${HOST}";
      nix = {
        version = "24.05";
      };
      homeManagerConfigurations = (user: home: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users = { ${user.name} = home; };
        };
      });
    in
    {
      # For user environments
      # - home-manager switch .#${USER}
      # - home-manager switch .#${USER}-wsl
      # For GitHub Actions
      # - home-manager switch .#runner
      # - home-manager switch .#runner-wsl
      homeConfigurations =
        let
          meta = rec {
            user = {
              # this line is replaced by the real user name as fallback
              name = "${USER}";
            };
            isCi = user.name == "${CI_USER}";
          };
          contexts = [
            {
              name = meta.user.name;
              meta = { inherit (meta) isCi; isWsl = false; };
            }
            {
              name = meta.user.name + "-wsl";
              meta = { inherit (meta) isCi; isWsl = true; };
            }
          ];
          generateConfiguration = (context:
            {
              name = context.name;
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                modules = [
                  ./home/linux.nix
                ];
                extraSpecialArgs = {
                  inherit nix meta;
                };
              };
            }
          );
        in
        nixpkgs.lib.listToAttrs
          (builtins.map (generateConfiguration) contexts);

      # For darwin
      # - darwin-rebuild switch .#${system}-$(USER)
      # For GitHub Actions
      # - darwin-rebuild switch .#${system}-runner
      darwinConfigurations =
        let
          system = "aarch64-darwin";
          meta = rec {
            user = {
              # this line is replaced by the real user name as fallback
              name = "${USER}";
            };
            isCi = user.name == "${CI_USER}";
            isWsl = false;
          };
        in
        {
          ${HOST} = nix-darwin.lib.darwinSystem rec {
            inherit system;
            pkgs = nixpkgs-darwin.legacyPackages.${system};
            modules = [
              ./hosts/darwin
              home-manager.darwinModules.home-manager
              (homeManagerConfigurations meta.user (import ./home/darwin.nix {
                inherit pkgs nix meta;
                lib = pkgs.lib;
              }))
            ];
            specialArgs = { inherit nix meta; };
          };
        };
    } // (flake-utils.lib.eachDefaultSystem
      (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell
          {
            buildInputs = with pkgs; [
              gnumake
              shellcheck
              shfmt
              nixpkgs-fmt
              yamlfmt
              dprint
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
