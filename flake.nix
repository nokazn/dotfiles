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
      USERNAME = "nokazn";
      HOSTNAME = "this is replaced to the real hostname by `apply/_inject-environment` in Makefile";
      users = [
        # For GitHub Actions
        { name = "runner"; host = "MKGP3JA.local"; isCi = true; }
        # HACK: this line is replaced by the real user name as fallback
        { name = "nokazn"; host = "MKGP3JA.local"; isCi = false; }
      ];
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
          systems = [{ isWsl = false; } { isWsl = true; }];
          generateConfigurations = (user: { isWsl }:
            {
              name =
                if isWsl then user.name + "-wsl" else user.name;
              value = home-manager.lib.homeManagerConfiguration {
                pkgs = nixpkgs.legacyPackages.x86_64-linux;
                modules = [
                  ./home/linux.nix
                ];
                extraSpecialArgs =
                  let
                    user = user // { inherit isWsl; };
                  in
                  {
                    inherit nix user;
                  };
              };
            }
          );
          generateConfigurationsPerUser = builtins.map
            generateConfigurations
            users;
        in
        nixpkgs.lib.listToAttrs
          (
            nixpkgs.lib.lists.flatten
              (
                builtins.map
                  (system: builtins.map
                    (generator: generator system)
                    generateConfigurationsPerUser)
                  systems
              )
          );

      # For darwin
      # - darwin-rebuild switch .#${system}-$(USER)
      # For GitHub Actions
      # - darwin-rebuild switch .#${system}-runner
      packages =
        let
          systems = [ "aarch64-darwin" "x86_64-darwin" ];
          generateConfiguration = (user: system: nix-darwin.lib.darwinSystem {
            name = system;
            value =
              let
                user = user // { isWsl = false; };
              in
              rec {
                inherit system;
                pkgs = nixpkgs-darwin.legacyPackages.${system};
                modules = [
                  ./hosts/darwin
                  home-manager.darwinModules.home-manager
                  (homeManagerConfigurations user (import ./home/darwin.nix {
                    inherit pkgs nix user;
                    lib = pkgs.lib;
                  }))
                ];
                specialArgs = { inherit nix user; };
              };
          });
          generateConfigurationsPerUser = builtins.map
            generateConfiguration
            users;
        in
        nixpkgs.lib.listToAttrs (
          nixpkgs.lib.lists.flatten (
            builtins.map
              (
                builtins.map
                  (system: builtins.map (generator: generator system) generateConfigurationsPerUser)
                  systems
              )
              users
          )
        );
      darwinConfigurations =
        let
          systems = [ "aarch64-darwin" "x86_64-darwin" ];
          generateContexts = map
            (system: user: ({
              inherit system;
              name = system + "-" + user.name;
              user = { inherit (user) name; };
              meta = {
                inherit (user) isCi;
                isWsl = false;
              };
            }))
            systems;
          contexts = nixpkgs.lib.flatten (
            map (generator: map generator users) generateContexts
          );
          generateConfiguration = (contexts:
            {
              name = contexts.name;
              value = with contexts; nix-darwin.lib.darwinSystem rec {
                inherit system;
                pkgs = nixpkgs-darwin.legacyPackages.${system};
                modules = [
                  ./hosts/darwin
                  home-manager.darwinModules.home-manager
                  (homeManagerConfigurations user (import ./home/darwin.nix {
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
