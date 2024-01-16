{ pkgs, lib, ... }:

with pkgs;
let
  packages = [
    black
    isort
    pipenv
    poetry
    python312
  ];
  pythonPackages = with python312Packages; [
    flake8
    setuptools
  ];
in
packages ++ lib.optionals (!stdenv.isDarwin) pythonPackages
