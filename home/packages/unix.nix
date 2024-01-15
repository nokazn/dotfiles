{ pkgs, ... }:

with pkgs; [
  gcc
  inetutils
  rename
  rsync
  unzip
  zip
] ++ lib.optional (!stdenv.isDarwin) [
  unixtools.column
]
