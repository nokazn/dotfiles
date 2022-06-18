{ config, pkgs, lib, ... }:

let
  nixPackages = import ./home/packages { pkgs = pkgs; lib = lib; };
  extraNodePackages = builtins.attrValues (import ./node { });
  username = "nokazn";
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.05";

    enableNixpkgsReleaseCheck = true;

    sessionVariables = import ./home/sessionVariables.nix { };
    shellAliases = import ./home/shellAliases.nix { };

    # nix packages
    packages = nixPackages ++ extraNodePackages;
    # dotfiles in home directory
    file = import ./home/files.nix { lib = lib; };
  };

  news = {
    # See https://github.com/nix-community/home-manager/blob/888eac32bd657bfe0d024c8770130d80d1c02cd3/home-manager/home-manager#L222-L253
    # See https://github.com/microsoft/WSL/issues/2466
    # prevent errors on executing notify-send in WSLg environment
    display = "silent";
  };

  programs = {
    bash = import ./programs/bash.nix { };
    zsh = import ./programs/zsh { pkgs = pkgs; } // {
      prezto = import ./programs/zsh/prezto.nix { };
    };
    direnv = import ./programs/direnv.nix { };
    fzf = import ./programs/fzf.nix { };
    go = import ./programs/go.nix { };
    neovim = import ./programs/neovim.nix { pkgs = pkgs; };
    nushell = import ./programs/nushell.nix { };
    starship = import ./programs/starship.nix { };
    tmux = import ./programs/tmux.nix { pkgs = pkgs; };
    vim = import ./programs/vim.nix { };
    zoxide = import ./programs/zoxide.nix { };
  };
}
