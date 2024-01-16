{ pkgs, lib, ... }:

let
  sources = builtins.filter
    (name: name != "default.nix")
    (lib.mapAttrsToList (name: value: name) (builtins.readDir ./.));
  packages = builtins.map
    (source: import (./. + "/${source}") { inherit pkgs lib; })
    sources;
in
lib.flatten packages
