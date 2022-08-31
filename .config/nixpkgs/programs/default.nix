{ lib, pkgs, ... }:

let
  inherit (builtins)
    readDir
    replaceStrings
    listToAttrs
    map;
  sources = lib.filter
    (source: !(source.type == "regular" && source.name == "default.nix"))
    (lib.mapAttrsToList
      (name: type: {
        name = name;
        type = type;
      })
      # 再帰的に探索しない
      (readDir ./.));
  programs = map
    (source:
      let
        name =
          if
            source.type == "regular"
          then (replaceStrings [ ".nix" ] [ "" ] source.name)
          else source.name;
      in
      {
        name = name;
        value = (import (./. + "/${source.name}") { pkgs = pkgs; });
      })
    sources;
in
listToAttrs programs
