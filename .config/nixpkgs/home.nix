{ config, pkgs, lib, ... }:

let
  nixPackages = import ./modules/packages.nix { pkgs = pkgs; };
  extraNodePackages = builtins.attrValues (import ./node/default.nix { });
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nokazn";
  home.homeDirectory = "/home/nokazn";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # nix packages
  home.packages = nixPackages ++ extraNodePackages;

  # dotfiles in home directory
  home.file = import ./modules/files.nix { lib = lib; };

  # programs settings
  programs.zsh = import ./programs/zsh { } // {
    prezto = import ./programs/zsh/prezto.nix { };
  };
  programs.direnv = import ./programs/direnv.nix { };
  programs.neovim = import ./programs/neovim.nix { pkgs = pkgs; };
  programs.starship = import ./programs/starship.nix { };
  programs.tmux = import ./programs/tmux.nix { pkgs = pkgs; };
  programs.vim = import ./programs/vim.nix { };
}
