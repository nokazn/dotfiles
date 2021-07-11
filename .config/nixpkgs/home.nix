{ config, pkgs, ... }:

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
  home.packages = [
    pkgs.git
    pkgs.gitAndTools.gh
    pkgs.gitAndTools.delta
    pkgs.gist
    pkgs.php
    pkgs.php74Packages.composer
    pkgs.google-cloud-sdk
    pkgs.aws
    pkgs.heroku
    pkgs.yarn
    pkgs.redis
    pkgs.memcached
    pkgs.google-chrome
    pkgs.vimHugeX
    pkgs.direnv
    pkgs.sl
    pkgs.neofetch
    pkgs.colordiff
    pkgs.htop
    pkgs.tree
    pkgs.nkf
    pkgs.tldr
    pkgs.jq
    pkgs.yq
    pkgs.ncdu
    pkgs.inetutils
    pkgs.tmux
    pkgs.rsync
    pkgs.gcc
    pkgs.bat
    pkgs.exa
    pkgs.broot
    pkgs.hyperfine
    pkgs.tokei
    pkgs.gping
    pkgs.shellcheck
    pkgs.expect
    pkgs.unzip
    pkgs.mkcert
    pkgs.lazygit
    pkgs.dive
    pkgs.pastel
    pkgs.act
    pkgs.powershell
    pkgs.xfce.thunar
    pkgs.gnome.gedit
  ];
}
