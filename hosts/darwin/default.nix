{ user, ... }:

{
  # necessary for nix-darwin
  services.nix-daemon.enable = true;

  users.users = {
    ${user.name} = {
      home = "/Users/${user.name}";
      shell = "zsh";
    };
  };

  homebrew = import ./homebrew.nix { };

  system.defaults = import ./system.nix { };
}
