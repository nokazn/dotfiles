{ pkgs, ... }:

with pkgs; [
  gcc
  inetutils
  rename
  rsync
  unixtools.column
  unzip
  zip
]
