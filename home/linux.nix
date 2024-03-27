{ pkgs, lib, user, nix, meta, ... }:

let
  args = { inherit pkgs lib meta; };
  nixPackages = import ../modules/packages args;
  extraNodePackages = builtins.attrValues (import ../modules/node { inherit pkgs; });
in
{
  home = {
    username = user.name;
    homeDirectory = "/home/${user.name}";
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

    sessionVariables = import ../modules/sessionVariables.nix args;
    shellAliases = import ../modules/shellAliases.nix { inherit meta; };

    # nix packages
    packages = nixPackages ++ extraNodePackages;
    # dotfiles in home directory
    file = import ../modules/files args;
  };

  news = {
    # See https://github.com/nix-community/home-manager/blob/888eac32bd657bfe0d024c8770130d80d1c02cd3/home-manager/home-manager#L222-L253
    # See https://github.com/microsoft/WSL/issues/2466
    # prevent errors on executing notify-send in WSLg environment
    display = "silent";
  };

  programs = import ../programs args;

  services = {
    gpg-agent = import ../modules/services/gpg-agent.nix args;
    keybase = import ../modules/services/keybase.nix { };
  };
}
