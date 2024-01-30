{ pkgs, lib, user, nix, meta, ... }:

let
  nixPackages = import ../modules/packages { inherit pkgs lib meta; };
  extraNodePackages = builtins.attrValues (import ../modules/node { inherit pkgs; });
in
{
  home = {
    username = user.name;
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = nix.version;

    enableNixpkgsReleaseCheck = true;
    extraOutputsToInstall = [ "dev" ];

    sessionVariables = import ../modules/sessionVariables.nix { inherit pkgs lib meta; };
    shellAliases = import ../modules/shellAliases.nix { inherit meta; };

    # nix packages
    packages = nixPackages ++ extraNodePackages;
    # dotfiles in home directory
    file = import ../modules/files { inherit pkgs lib meta; };
  };

  programs = import ../programs { inherit pkgs lib meta; };
}
