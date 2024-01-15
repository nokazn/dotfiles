{
  description = "Home Manager configuration of nokazn";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.11";

    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, home-manager, darwin, flake-utils, ... }:
    let
      homeManagerConfigurations = (home: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.nokazn = home;
        };
      });
    in
    {
      # For Linux user environments
      homeConfigurations."nokazn" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./.config/home-manager/home.nix ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      # For darwin
      darwinConfigurations = nixpkgs.lib.listToAttrs (builtins.map (system: {
        name = system;
        value = darwin.lib.darwinSystem rec {
          inherit system;
          pkgs = nixpkgs-darwin.legacyPackages.${system};
          modules = [
            ./hosts/darwin.nix
            home-manager.darwinModules.home-manager
            (homeManagerConfigurations (import ./home/darwin.nix {
              inherit pkgs;
              lib = pkgs.lib;
            }))
          ];
        };
      }) [ "aarch64-darwin" "x86_64-darwin" ]);
    };
}
