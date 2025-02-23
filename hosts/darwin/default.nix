{ meta, pkgs, ... }:

{
  users.users = {
    ${meta.user.name} = {
      home = "/Users/${meta.user.name}";
      shell = pkgs.zsh;
    };
  };

  homebrew = if meta.isCi then { } else import ./homebrew.nix { };

  # For compatibility for lecacy Nix build uiser group ID by nix-darwin
  ids.gids.nixbld = 30000;

  system = {
    stateVersion = 5;
    defaults = import ./system.nix { };
  };
}
