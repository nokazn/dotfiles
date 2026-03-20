{ pkgs, ... }:
with pkgs;
[
  alejandra
  nil
  nix-prefetch-git
  nix-update
  nixfmt
  nixpkgs-lint
  nixpkgs-review
  nurl
]
