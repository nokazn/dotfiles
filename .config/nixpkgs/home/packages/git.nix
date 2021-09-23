{ pkgs, ... }:

with pkgs; [
  git
  gist # Gist lets you upload to https://gist.github.com/
  gitAndTools.gh # Work seamlessly with GitHub from the command line
  gitAndTools.delta # viewer for git and diff output
  pre-commit
]
