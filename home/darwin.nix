{
  pkgs,
  lib,
  nix,
  meta,
  ...
}:

let
  args = { inherit pkgs lib meta; };
  nixPackages = import ../modules/packages args;
  npmPackages = builtins.attrValues (
    import ../modules/node/default.nix {
      inherit pkgs;
      nodejs = pkgs.nodejs_22;
    }
  );
in
{
  home = {
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
    packages = nixPackages ++ npmPackages;
    # dotfiles in home directory
    file = import ../modules/files args;
  };

  programs = import ../programs args;
}
