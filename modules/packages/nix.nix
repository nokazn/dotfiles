{ pkgs, ... }:
with pkgs; [
  alejandra
  nil
  nixfmt
  nixpkgs-lint
  nixpkgs-review
  nix-prefetch-git
  nurl
]
