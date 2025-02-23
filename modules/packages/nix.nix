{ pkgs, ... }:
with pkgs; [
  alejandra
  nil
  nixfmt-rfc-style
  nixpkgs-lint
  nixpkgs-review
  nix-prefetch-git
  nurl
]
