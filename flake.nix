{
  description = "Home Manager configuration of nokazn";

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
  };

  outputs =
    inputs@{ nixpkgs
    , nixpkgs-darwin
    , nix-darwin
    , home-manager
    , ...
    }:
    let
      homeManagerConfigurations = (home: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.nokazn = home;
        };
      });
      user = {
        name = "nokazn";
      };
    in
    {
      # For Linux user environments
      homeConfigurations.${user.name} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./home/linux.nix
        ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };

      # For darwin
      darwinConfigurations = nixpkgs.lib.listToAttrs (builtins.map
        (system: {
          name = system;
          value = nix-darwin.lib.darwinSystem rec {
            inherit system;
            pkgs = nixpkgs-darwin.legacyPackages.${system};
            modules = [
              ./hosts/darwin.nix
              home-manager.darwinModules.home-manager
              (homeManagerConfigurations (import ./home/darwin.nix {
                inherit pkgs user nix;
                lib = pkgs.lib;
              }))
            ];
            specialArgs = { inherit user nix; };
          };
        }) [ "aarch64-darwin" "x86_64-darwin" ]);
    };
}
