{ meta, ... }:

{
  # necessary for nix-darwin
  services.nix-daemon.enable = true;

  users.users = {
    ${meta.user.name} = {
      home = "/Users/${meta.user.name}";
      shell = "zsh";
    };
  };

  homebrew = if meta.isCi then { } else import ./homebrew.nix { };

  system = {
    stateVersion = 5;
    defaults = import ./system.nix { };
  };
}
