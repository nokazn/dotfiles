{ ... }:

let
  commonShellConfig = (import ../shell.nix { });
in
{
  enable = true;
  historySize = 10000;
  historyFileSize = 100000;
  historyIgnore = [
    "ls"
    "cd"
  ];
  bashrcExtra = builtins.readFile ../../../.bashrc + commonShellConfig.init;
  profileExtra = builtins.readFile ../../../.bash_profile + commonShellConfig.profile;
}
