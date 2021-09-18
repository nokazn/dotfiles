{ pkgs, ... }:

with pkgs; [
  # Git tools  ----------------------------------------------------------------------------------------------------
  git
  gitAndTools.gh                    # Work seamlessly with GitHub from the command line
  gitAndTools.delta                 # viewer for git and diff output
  gist                              # Gist lets you upload to https://gist.github.com/
  # specific language related tools ----------------------------------------------------------------------------------------------------
  php
  php74Packages.composer
  yarn
  # CLI tools for public cloud services ----------------------------------------------------------------------------------------------------
  google-cloud-sdk
  awscli2
  heroku
  # GUI Apps ----------------------------------------------------------------------------------------------------
  google-chrome
  # classic CLI tools ----------------------------------------------------------------------------------------------------
  gcc
  gnome.gedit                       # The default text editor of the GNOME desktop environment and part of the GNOME Core Applications
  rsync
  xfce.thunar                       # A file manager for Linux and other Unix-like systems
  inetutils
  sl
  zip
  unzip
  tree                              # Recursive directory listing command
  unixtools.column
  redis
  memcached
  # modern CLI tools ----------------------------------------------------------------------------------------------------
  starship
  neofetch                          # CLI system information tool written in BASH that displays information about your system next to an image, your OS logo, or any ASCII file of your choice
  direnv
  fzf                               # A command-line fuzzy finder written in Go
  nkf                               # A Kanji code converter among networks
  shellcheck                        # A static analysis tool for shell scripts
  expect
  tldr                              # A collection of community-maintained help pages for command-line tools
  jq                                # A lightweight and flexible command-line JSON processor
  yq                                # Command-line YAML processor - jq wrapper for YAML documents
  tokei                             # compiled with serialization support: json, cbor, yaml
  mkcert                            # A simple zero-config tool to make locally trusted development certificates with any names you'd like.
  lazygit                           # A simple terminal UI for git commands
  lazydocker                        # The lazier way to manage everything docker
  dive                              # A tool for exploring each layer in a docker image
  ncdu                              # A disk usage analyzer with an ncurses interface
  pastel                            # A command-line tool to generate, analyze, convert and manipulate colors
  act                               # Run your GitHub Actions locally 噫
  hyperfine                         # A command-line benchmarking tool
  powershell
  # modern command replacements ----------------------------------------------------------------------------------------------------
  colordiff                         # Compare FILES line by line.hto
  procs                             # A modern replacement for ps written in Rust
  htop                              # A cross-platform interactive process viewer
  bat                               # A cat(1) clone with syntax highlighting and Git integration
  exa                               # A modern replacement for the venerable file-listing command-line program
  fd                                # A simple, fast and user-friendly alternative to 'find'
  ripgrep                           # An interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
  broot                             # A new way to see and navigate directory trees
  gping                             # Ping, but with a graph
  # Node.js packages ----------------------------------------------------------------------------------------------------
  nodePackages.eslint
  nodePackages.firebase-tools
  nodePackages.lerna
  nodePackages.netlify-cli
  nodePackages.node-gyp
  nodePackages.prettier
  nodePackages.serverless
  nodePackages.typescript
  nodePackages.webpack-cli
  # Go
  ghq
  gore
  gopls
  # Python
  pipenv
]
