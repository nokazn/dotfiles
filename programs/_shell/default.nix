{ ... }:

let
  aliases = builtins.readFile ./aliases.sh;
  paths = builtins.readFile ../../unix/.path.sh;
  profile = builtins.readFile ./profile.sh;
in
{
  init = "\n" + aliases + "\n" + paths;
  profile = "\n" + profile;
}
