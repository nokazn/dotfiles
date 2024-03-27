{ pkgs, ... }:

let
  commonShellConfig = import ../_shell { };
  preztoConfig = import ./prezto.nix { };
in
{
  enable = true;
  autosuggestion = {
    enable = true;
  };
  enableCompletion = true;
  syntaxHighlighting = {
    enable = true;
  };
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
  initExtra = commonShellConfig.init + ''
    # FIXME: デバッグ用
    # if (which zprof > /dev/null) ;then
    #   zprof | less
    # fi
  '';
  loginExtra = commonShellConfig.profile;
  envExtra = ''
    # FIXME: デバッグ用
    # zmodload zsh/zprof && zprof
  '';
  prezto = preztoConfig;
}
