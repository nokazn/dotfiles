{ pkgs, ... }:

with pkgs; [
  expect
  gcc
  inetutils
  rename
  rsync
  unzip
  zip
] ++ lib.optionals stdenv.isLinux [
  unixtools.column
]
