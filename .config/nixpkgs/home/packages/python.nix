{ pkgs, ... }:

with pkgs;
let
  packages = [
    black
    pipenv
    poetry
    python39
  ];
  pythonPackages = with python39Packages; [
    flake8
    isort
    pip
    setuptools
  ];
in
packages ++ pythonPackages
