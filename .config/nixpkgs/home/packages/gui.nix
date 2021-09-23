{ pkgs, ... }:

with pkgs; [
  google-chrome
  gnome.gedit # The default text editor of the GNOME desktop environment and part of the GNOME Core Applications
  xfce.thunar # A file manager for Linux and other Unix-like systems
]
