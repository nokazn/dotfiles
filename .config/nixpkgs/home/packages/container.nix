{ pkgs, ... }:

with pkgs; [
  daemonize
  docker
  docker-compose
  podman
  podman-compose
  kubernetes
]
