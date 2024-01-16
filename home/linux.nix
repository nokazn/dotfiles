{ pkgs, lib, ... }:

let
  nixPackages = import ../modules/packages { inherit pkgs lib; };
  extraNodePackages = builtins.attrValues (import ../modules/node { inherit pkgs; });
in
{
  home = rec {
    username = "nokazn";
    homeDirectory = "/home/${username}";
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

    sessionVariables = import ../modules/sessionVariables.nix { };
    shellAliases = import ../modules/shellAliases.nix { };

    # nix packages
    packages = nixPackages ++ extraNodePackages;
    # dotfiles in home directory
    file = import ../modules/files { inherit pkgs lib; };
  };

  news = {
    # See https://github.com/nix-community/home-manager/blob/888eac32bd657bfe0d024c8770130d80d1c02cd3/home-manager/home-manager#L222-L253
    # See https://github.com/microsoft/WSL/issues/2466
    # prevent errors on executing notify-send in WSLg environment
    display = "silent";
  };

  programs = import ../programs { inherit pkgs lib; };

  services = {
    gpg-agent = import ../modules/services/gpg-agent.nix { };
    keybase = import ../modules/services/keybase.nix { };
  };
}
