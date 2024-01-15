{ ... }:

let
  username = "nokazn";
in
{
  # necessary for nix-darwin
  services.nix-daemon.enable = true;

  users.users = {
    ${username} = {
      home = "/Users/${username}";
      shell = "zsh";
    };
  };
}
