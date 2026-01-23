{ pkgs, lib, ... }:

with pkgs;
lib.optionals stdenv.isLinux [
  # google-chrome
  gedit # The default text editor of the GNOME desktop environment and part of the GNOME Core Applications
  thunar # A file manager for Linux and other Unix-like systems
]
