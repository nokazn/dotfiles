let
  files = [
    ".config/git/attributes"
    ".config/git/ignore"
    ".bash_aliases"
    ".bash_profile"
    ".bashrc"
    ".gitconfig"
    ".npmrc"
    ".path.sh"
    ".prettierrc.json"
    ".profile"
    ".shellcheckrc"
    ".shrc.sh"
    ".tmux.conf"
    ".vimrc"
    ".zlogin"
    ".zlogout"
    ".zprofile"
    ".zshenv"
    ".zshrc"
  ];
  fileSourceList = builtins.map (file: {
    name = file;
    value = {
      source = ../../.. + ("/" + file);
    };
  }) files;
in builtins.listToAttrs fileSourceList
