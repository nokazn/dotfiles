{ pkgs, ... }:

with pkgs; [
  bash
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
