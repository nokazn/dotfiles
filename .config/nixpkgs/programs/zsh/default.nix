{ ... }:

let
  commonShellConfig = (import ../../shell.nix { });
in
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
  initExtra = builtins.readFile ../../../../.zshrc + commonShellConfig.init;
  loginExtra = builtins.readFile ../../../../.zlogin + commonShellConfig.profile;
  logoutExtra = builtins.readFile ../../../../.zlogout;
}
