{ ... }:

{
  enable = true;
  color = true;
  # Prezto modules to load (https://github.com/sorin-ionescu/prezto/tree/master/modules)
  pmodules = [
    "environment"
    "terminal"
    "editor"
    "history"
    "directory"
    "spectrum"
    "utility"
    "completion"
    "git"
  ];
  editor.keymap = "vi";
  git.submoduleIgnore = "all";
  ssh.identities = [
    "id_rsa"
    "id_rsa2"
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
}
