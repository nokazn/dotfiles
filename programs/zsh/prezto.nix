{ ... }:

{
  enable = true;
  color = true;
  # Prezto modules to load (https://github.com/sorin-ionescu/prezto/tree/master/modules)
  pmodules = [
    "git"
    "utility"
    "completion"
    "directory"
    "editor"
    "environment"
    "history"
  ];
  editor.keymap = "vi";
  git.submoduleIgnore = "all";
  prompt.theme = "off";
  ssh.identities = [
    "id"
    "id2"
    "github"
    "gitlab"
  ];
  syntaxHighlighting.highlighters = [
    "main"
    "brackets"
    "pattern"
    "line"
    "cursor"
    "root"
  ];
  extraConfig = ''
    zstyle ':prezto:module:git:alias' skip 'yes'

    # コマンドの補完が激遅になるため
    unsetopt PATH_DIRS
    unsetopt AUTO_PARAM_SLASH
  '';
}
