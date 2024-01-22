{ pkgs, lib, meta, ... }:

let
  sources = builtins.filter
    (name: name != "default.nix")
    (lib.mapAttrsToList (name: value: name) (builtins.readDir ./.));
  packages = builtins.map
    (source: import (./. + "/${source}") { inherit pkgs lib meta; })
    sources;
in
lib.flatten packages
