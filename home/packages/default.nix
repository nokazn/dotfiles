{ lib, pkgs, ... }:

let
  sources = builtins.filter
    (name: name != "default.nix")
    (lib.mapAttrsToList (name: value: name) (builtins.readDir ./.));
  packages = builtins.map
    (source: import (./. + "/${source}") { pkgs = pkgs; })
    sources;
in
lib.flatten packages
