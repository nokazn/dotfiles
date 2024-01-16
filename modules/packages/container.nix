{ pkgs, lib, ... }:

with pkgs; [
  dive # A tool for exploring each layer in a docker image
  lazydocker # The lazier way to manage everything docker
  podman
  podman-compose
] ++ lib.optionals (!stdenv.isDarwin) [
  kubernetes
]
