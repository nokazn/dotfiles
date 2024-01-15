{ pkgs, ... }:

with pkgs; [
  alejandra
  nixpkgs-fmt
  nixpkgs-lint
  nix-prefetch-git
]
