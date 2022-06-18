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
  plugins = [
    {
      # zsh completion for docker
      name = "docker-zsh-completion";
      src = pkgs.fetchFromGitHub {
        owner = "greymd";
        repo = "docker-zsh-completion";
        rev = "master";
        sha256 = "0p639lqv9hryni02r9ra0zh8wwj78grnv68gy2jij5v3vmkfrjjs";
      };
    }
  ];
  envExtra = builtins.readFile ../../../../.zshenv;
  initExtra = builtins.readFile ../../../../.zshrc + commonShellConfig.init;
  loginExtra = builtins.readFile ../../../../.zlogin + commonShellConfig.profile;
  logoutExtra = builtins.readFile ../../../../.zlogout;
}
