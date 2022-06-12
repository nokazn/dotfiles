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
  shellAliases =
    let
      hasDircolors = builtins.pathExists /usr/bin/dircolors;
    in
    if hasDircolors then
      {
        ls = "ls --color=auto";
        dir = "dir --color=auto";
        vdir = "vdir --color=auto";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
      }
    else
      { };
  bashrcExtra =
    builtins.readFile ../../../.bashrc
    + commonShellConfig.init
    + ''
      # enable color support of ls and also add handy aliases
      if [[ -x /usr/bin/dircolors ]]; then
        if [[ -r ~/.dircolors ]]; then
          eval "$(dircolors -b ~/.dircolors)"
        else
          eval "$(dircolors -b)"
        fi
      fi
    '';
  profileExtra = builtins.readFile ../../../.bash_profile + commonShellConfig.profile;
}
