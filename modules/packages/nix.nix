{ pkgs, ... }:
with pkgs; [
  alejandra
  nil
  nixpkgs-fmt
  nixpkgs-lint
  nix-prefetch-git
  nurl
]
