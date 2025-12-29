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
    {
      nixpkgs,
      nixpkgs-darwin,
      nix-darwin,
      home-manager,
      flake-utils,
      ...
    }:
    let
      USER = "runner";
      # this line is replaced by the real user name as fallback
      user = {
        # this line is replaced by the real user name as fallback
        name = "nokazn";
      };
      # whether username is the one in GitHub Actions
      isCi = user.name == "runner";
      # this line is replaced by the real user name as fallback
      HOST = "um890pro";
      nix = {
        version = "25.05";
      };
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkg.pname or (nixpkgs.lib.getName pkg)) [
          "claude-code"
        ];
      homeManagerConfigurations = (
        home: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users = {
              ${user.name} = home;
            };
          };
        }
      );
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
          generateConfiguration = (
            { isWsl }:
            {
              name = user.name + (if isWsl then "-wsl" else "");
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = import nixpkgs {
                  system = "x86_64-linux";
                  config.allowUnfreePredicate = allowUnfreePredicate;
                };
                modules = [
                  ./home/linux.nix
                ];
                extraSpecialArgs = {
                  inherit nix;
                  meta = { inherit user isWsl isCi; };
                };
              };
            }
          );
        in
        nixpkgs.lib.listToAttrs (
          builtins.map generateConfiguration [
            { isWsl = true; }
            { isWsl = false; }
          ]
        );

      # For darwin
      # - darwin-rebuild switch .#${system}-$(USER)
      # For GitHub Actions
      # - darwin-rebuild switch .#${system}-runner
      darwinConfigurations =
        let
          system = "aarch64-darwin";
          meta = {
            inherit user isCi;
            isWsl = false;
          };
        in
        {
          ${HOST} = nix-darwin.lib.darwinSystem rec {
            inherit system;
            pkgs = import nixpkgs-darwin {
              inherit system;
              config.allowUnfreePredicate = allowUnfreePredicate;
            };
            modules = [
              ./hosts/darwin
              home-manager.darwinModules.home-manager
              (homeManagerConfigurations (
                import ./home/darwin.nix {
                  inherit pkgs nix meta;
                  lib = pkgs.lib;
                }
              ))
            ];
            specialArgs = { inherit nix meta; };
          };
        };
    }
    // (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = allowUnfreePredicate;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            gnumake
            shellcheck
            shfmt
            nixfmt-rfc-style
            yamlfmt
            dprint
            pre-commit
            treefmt
          ];
        };
      }
    ));

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    auto-optimise-store = true;
    eval-cache = true;
  };
}
