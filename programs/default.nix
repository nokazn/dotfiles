{ lib, pkgs, meta, ... }:

let
  inherit (builtins)
    readDir
    replaceStrings
    listToAttrs
    map;
  sources = lib.filter
    (source:
      let
        isEntryPoint = source.type == "regular" && source.name == "default.nix";
        # `_`で始まるファイル/ディレクトリは除外
        isInternal = (builtins.match "^_.+" source.name) != null;
      in
      !isEntryPoint && !isInternal
    )
    (lib.mapAttrsToList
      (name: type: { inherit name type; })
      # 再帰的に探索しない
      (readDir ./.)
    );
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
        inherit name;
        value = (import (./. + "/${source.name}") { inherit pkgs meta; });
      })
    sources;
in
listToAttrs programs
