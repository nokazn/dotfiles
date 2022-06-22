{ pkgs, ... }:

with pkgs; [
  docker-compose
  podman
  podman-compose
  kubernetes
]
