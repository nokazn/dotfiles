{ ... }:

let
  aliases = builtins.readFile ./.sh_aliases;
  paths = builtins.readFile ../../unix/.path.sh;
  profile = builtins.readFile ./.sh_profile.sh;
in
{
  init = "\n" + aliases + "\n" + paths;
  profile = "\n" + profile;
}
