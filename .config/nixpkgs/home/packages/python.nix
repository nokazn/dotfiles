{ pkgs, ... }:

with pkgs;
let
  packages = [
    pipenv
    python39
  ];
  pythonPackages = with python39Packages; [
    pip
    setuptools
  ];
in
packages ++ pythonPackages
