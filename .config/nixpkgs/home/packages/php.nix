{ pkgs, ... }:

with  pkgs; [
  php
  php81Packages.composer
]
