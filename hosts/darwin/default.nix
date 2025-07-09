{ meta, pkgs, ... }:

{
  users.users = {
    ${meta.user.name} = {
      home = "/Users/${meta.user.name}";
      shell = pkgs.zsh;
    };
  };

  homebrew = if meta.isCi then { } else import ./homebrew.nix { };

  system = {
    stateVersion = 5;
    defaults = import ./system.nix { };
  };
}
