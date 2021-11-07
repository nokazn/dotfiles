{ pkgs, ... }:

with pkgs;
let
  packages = [
    black
    pipenv
    poetry
    python39Full
  ];
  pythonPackages = with python39Packages; [
    flake8
    isort
    pip
    setuptools
  ];
in
packages ++ pythonPackages
