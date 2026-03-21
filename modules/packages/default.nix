{
  pkgs,
  lib,
  meta,
  ...
}:

let
  profile = meta.profile or "minimum";
  excludeByProfile = {
    minimum = [ "private.nix" "work.nix" ];
    private = [ "work.nix" ];
    work = [ "private.nix" ];
  };
  excludeFiles = [ "default.nix" ] ++ (excludeByProfile.${profile} or excludeByProfile.minimum);
  sources = builtins.filter
    (name: !builtins.elem name excludeFiles && !lib.hasPrefix "_" name)
    (lib.mapAttrsToList (name: _: name) (builtins.readDir ./.));
  packages = builtins.map (source: import (./. + "/${source}") { inherit pkgs lib meta; }) sources;
in
lib.flatten packages
