{ ... }:

{
  enable = true;
  enableAutosuggestions = true;
  # TODO https://github.com/nix-community/home-manager/issues/1929
  enableCompletion = false;
  enableSyntaxHighlighting = true;
  autocd = true;
  history = {
    extended = true;
    ignoreDups = true;
    path = "$HOME/.zsh_history";
    save = 10000;
    share = true;
    size = 10000;
  };
  envExtra = builtins.readFile ../../../../.zshenv;
  initExtra = builtins.readFile ../../../../.zshrc;
  loginExtra = builtins.readFile ../../../../.zlogin;
  logoutExtra = builtins.readFile ../../../../.zlogout;
}
