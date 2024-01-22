{ pkgs, lib, ... }:

with pkgs; lib.optionals stdenv.isLinux [
  fcitx5
  fcitx5-mozc
]
