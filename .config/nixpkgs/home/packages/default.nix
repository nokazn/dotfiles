{ lib, pkgs, ... }:

let
  sources = [
    "cli"
    "cloud"
    "container"
    "deno"
    "git"
    "go"
    "gui"
    "java"
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
