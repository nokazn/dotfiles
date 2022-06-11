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
    # nix packages
    packages = nixPackages ++ extraNodePackages;
    # dotfiles in home directory
    file = import ./home/files.nix { lib = lib; };
  };

  programs = {
    bash = import ./programs/bash.nix { };
    zsh = import ./programs/zsh { } // {
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
  };
}
