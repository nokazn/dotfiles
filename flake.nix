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
    { nixpkgs
    , nixpkgs-darwin
    , nix-darwin
    , home-manager
    , flake-utils
    , ...
    }:
    let
      users = [
        { name = "nokazn"; isCi = false; }
        # For GitHub Actions
        { name = "runner"; isCi = true; }
      ];
      nix = {
        version = "23.11";
      };
      homeManagerConfigurations = (home: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users =
            let
              userAttrs = map (user: with user; { inherit name; value = home; }) users;
            in
            nixpkgs.lib.listToAttrs userAttrs;
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
          generateContext = (user:
            map (context: context // { inherit user; })
              (with user; [
                {
                  name = name;
                  meta = { inherit isCi; isWsl = false; };
                }
                {
                  name = name + "-wsl";
                  meta = { inherit isCi; isWsl = true; };
                }
              ])
          );
          contexts = nixpkgs.lib.lists.flatten (map generateContext users);
          generateConfiguration = (context:
            {
              name = context.name;
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                modules = [
                  ./home/linux.nix
                ];
                extraSpecialArgs = with context; {
                  inherit nix user meta;
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
          systems = [ "aarch64-darwin" "x86_64-darwin" ];
          contextGenerators = map
            (system: user: (with user; {
              inherit user system;
              name = system + "-" + name;
              meta = { inherit isCi; isWsl = false; };
            }))
            systems;
          contexts = nixpkgs.lib.flatten (
            map (generator: map generator users) contextGenerators
          );
          generateConfiguration = (context:
            {
              name = context.name;
              value = with context; nix-darwin.lib.darwinSystem rec {
                inherit system;
                pkgs = nixpkgs-darwin.legacyPackages.${system};
                modules = [
                  ./hosts/darwin
                  home-manager.darwinModules.home-manager
                  (homeManagerConfigurations (import ./home/darwin.nix {
                    inherit pkgs nix user meta;
                    lib = pkgs.lib;
                  }))
                ];
                specialArgs = { inherit user nix meta; };
              };
            });
        in
        nixpkgs.lib.listToAttrs
          (builtins.map generateConfiguration contexts);

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
