{ pkgs, ... }:

with pkgs; [
  podman
  podman-compose
  kubernetes
]
