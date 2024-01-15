{ pkgs, lib, ... }:

let
  nixPackages = lib.flatten (builtins.map
    (source: import source { pkgs = pkgs; lib = lib; })
    [
      ./packages/cli.nix
      ./packages/cloud.nix
      ./packages/container.nix
      ./packages/git.nix
      ./packages/go.nix
      ./packages/gui.nix
      ./packages/java.nix
      ./packages/langs.nix
      ./packages/nix.nix
      ./packages/node.nix
      ./packages/php.nix
      ./packages/python.nix
      ./packages/unix.nix
    ]);
  extraNodePackages = builtins.attrValues (import ../.config/home-manager/node { pkgs = pkgs; });
  username = "nokazn";
in
{
  home = {
    inherit username;
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";

    enableNixpkgsReleaseCheck = true;
    extraOutputsToInstall = [ "dev" ];

    sessionVariables = import ../.config/home-manager/home/sessionVariables.nix { };
    shellAliases = import ../.config/home-manager/home/shellAliases.nix { };

    # nix packages
    packages = nixPackages ++ extraNodePackages;
    # dotfiles in home directory
    file = import ../.config/home-manager/home/files.nix { lib = lib; };
  };

  programs = import ../.config/home-manager/programs { lib = lib; pkgs = pkgs; };
}
