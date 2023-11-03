{ pkgs, ... }:

with pkgs; [
  nixpkgs-fmt
  nixpkgs-lint
  nix-prefetch-git
]
