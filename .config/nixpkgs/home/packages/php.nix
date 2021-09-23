{ pkgs, ... }:

with  pkgs; [
  php
  php74Packages.composer
]
