{ pkgs, ... }:

with pkgs; [
  cue # A data constraint language which aims to simplify tasks involving defining and using data
  deno
  elmPackages.elm
  elmPackages.elm-format
  erlang
  lua
  nim
  rustup
]
