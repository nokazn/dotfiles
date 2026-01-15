{ meta, pkgs, ... }:

{
  # Disable nix-darwin's Nix management to avoid conflict with Determinate.
  nix.enable = false;

  users.users = {
    ${meta.user.name} = {
      home = "/Users/${meta.user.name}";
      shell = pkgs.zsh;
    };
  };

  homebrew = if meta.isCi then { } else import ./homebrew.nix { };

  system = {
    stateVersion = 5;
    primaryUser = meta.user.name;
    defaults = import ./system.nix { };
  };
}
