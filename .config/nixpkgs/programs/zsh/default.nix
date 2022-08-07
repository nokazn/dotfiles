{ pkgs, ... }:

let
  commonShellConfig = (import ../../shell.nix { });
in
{
  enable = true;
  enableAutosuggestions = true;
  # TODO: https://github.com/NixOS/nix/issues/5445
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
  shellAliases = {
    zsh-login-benchmark = "time ( zsh -i -c exit )";
  };
  plugins = with pkgs; [
    {
      # zsh completion for docker
      name = "docker-zsh-completion";
      src = fetchFromGitHub {
        owner = "greymd";
        repo = "docker-zsh-completion";
        rev = "6e080c179a611644a944d3e5981eb65aef6e0dd5";
        # TODO: https://github.com/NixOS/nix/issues/1880
        sha256 = "ElLHKoISABbVKQmeRmg0KXHm5/2PGTa9OmZs+73xLbs=";
      };
    }
  ];
  envExtra = builtins.readFile ../../../../.zshenv;
  initExtra = builtins.readFile ../../../../.zshrc + commonShellConfig.init;
  loginExtra = builtins.readFile ../../../../.zlogin + commonShellConfig.profile;
  logoutExtra = builtins.readFile ../../../../.zlogout;
}
