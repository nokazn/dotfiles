{ pkgs, ... }:

with pkgs; [
  expect
  gcc
  inetutils
  pinentry
  rename
  rsync
  unzip
  zip
] ++ lib.optional stdenv.isLinux [
  unixtools.column
]
