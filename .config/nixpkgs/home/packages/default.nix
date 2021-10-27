{ lib, pkgs, ... }:

let
  sources = [
    "cli"
    "cloud"
    "container"
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
