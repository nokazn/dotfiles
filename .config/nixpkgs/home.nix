{ config, pkgs, ... }:

let
  nixPackages = import ./modules/packages.nix { pkgs = pkgs; };
  extraNodePackages = with import ./node/default.nix {}; [
    # TODO: 入れられない
    # https://discourse.nixos.org/t/aws-cdk-node-modules-json-addition-failing-at-yaml-dependency/12812
    # aws-cdk
    # "@nestjs/cli"
    # "@octokit/core"
    envinfo
    generator-code
    http-server
    minimum-node-version
    sort-package-json
    ts-node
    vercel
    yo
  ];
  files = import ./modules/files.nix;
in rec {
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
  home.file = files;

  programs.zsh = {
    enable = true;
  };

  programs.zsh.prezto = {
    enable = true;
    color = true;
    # the Prezto modules to load (browse modules)
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
  };

  programs.vim = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
  };

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    plugins = with pkgs; [
      {
        # A set of tmux options that should be acceptable to everyone
        plugin = tmuxPlugins.sensible;
      }
      {
        # Saves all the little details from your tmux environment
        plugin = tmuxPlugins.resurrect;
      }
      {
        # Copying to system clipboard
        plugin = tmuxPlugins.yank;
      }
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
