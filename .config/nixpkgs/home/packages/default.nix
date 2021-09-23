{ lib, pkgs, ... }:

let
  sources = [
    "cli"
    "cloud"
    "git"
    "go"
    "gui"
    "nix"
    "node"
    "php"
    "python"
    "unix"
  ];
  packages = builtins.map
    (source: import (./. + "/${source}.nix") { pkgs = pkgs; })
    sources;
in
lib.flatten packages
