{ pkgs, ... }:

with pkgs; [
  dive # A tool for exploring each layer in a docker image
  kubernetes
  lazydocker # The lazier way to manage everything docker
  podman
  podman-compose
]
