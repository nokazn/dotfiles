{ ... }:

{
  enable = true;
  color = true;
  # Prezto modules to load (browse modules)
  pmodules = [
    "environment"
    "terminal"
    "editor"
    "history"
    "directory"
    "spectrum"
    "utility"
    "completion"
    "prompt"
    "git"
    "node"
    "tmux"
  ];
  editor.keymap = "vi";
  git.submoduleIgnore = "all";
  prompt.theme = "steeef";
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
