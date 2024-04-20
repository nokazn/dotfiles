{ pkgs, ... }:
with pkgs; [
  alejandra
  nil
  nixpkgs-fmt
  nixpkgs-lint
  nixpkgs-review
  nix-prefetch-git
  nurl
]
