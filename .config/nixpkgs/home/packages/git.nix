{ pkgs, ... }:

with pkgs; [
  act # Run your GitHub Actions locally
  ghq # Remote repository management made easy
  git
  gist # Gist lets you upload to https://gist.github.com/
  gitAndTools.delta # viewer for git and diff output
  gitAndTools.gh # Work seamlessly with GitHub from the command line
  git-lfs # Git extension for versioning large files
  git-crypt # Transparent file encryption in git
  lazygit # A simple terminal UI for git commands
  pre-commit # A framework for managing and maintaining multi-language pre-commit hooks
]
