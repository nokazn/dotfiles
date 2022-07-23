{ ... }:

let
  aliases = builtins.readFile ../../.bash_aliases;
  paths = builtins.readFile ../../.path.sh;
  init = ''
    export GPG_TTY=$(tty)
  '';
  profile = builtins.readFile ../../.sh_profile.sh;
in
{
  init = "\n" + aliases + "\n" + paths;
  profile = "\n" + profile;
}
