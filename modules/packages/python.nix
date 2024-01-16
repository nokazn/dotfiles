{ pkgs, lib, ... }:

with pkgs;
let
  packages = [
    black
    pipenv
    poetry
    python312
  ];
  pythonPackages = with python312Packages; [
    flake8
    isort
    pip
    setuptools
  ];
in
packages ++ lib.optionals (!stdenv.isDarwin) pythonPackages
