{ pkgs, ... }:

with pkgs; [
  docker
  docker-compose
  podman
  podman-compose
  kubernetes
]
