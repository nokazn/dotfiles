{ pkgs, ... }:

with pkgs; let
  db = [
    redis
    memcached
  ];
  modern = [
    act # Run your GitHub Actions locally 噫
    asdf-vm # Extendable version manager with support for Ruby, Node.js, Erlang & more
    aws-vault # A vault for securely storing and accessing AWS credentials in development environments
    direnv
    dive # A tool for exploring each layer in a docker image
    dstat
    expect
    hyperfine # A command-line benchmarking tool
    gtop
    jq # A lightweight and flexible command-line JSON processor
    lazydocker # The lazier way to manage everything docker
    lazygit # A simple terminal UI for git commands
    mkcert # A simple zero-config tool to make locally trusted development certificates with any names you'd like.
    navi # An interactive cheatsheet tool for the command-line and application launchers
    ncdu # A disk usage analyzer with an ncurses interface
    neofetch # CLI system information tool written in BASH that displays information about your system next to an image, your OS logo, or any ASCII file of your choice
    nkf # A Kanji code converter among networks
    pastel # A command-line tool to generate, analyze, convert and manipulate colors
    powershell # Powerful cross-platform (Windows, Linux, and macOS) shell and scripting language based on .NET
    sampler # Tool for shell commands execution, visualization and alerting. Configured with a simple YAML file.
    shellcheck # A static analysis tool for shell scripts
    sl # SL(1): Cure your bad habit of mistyping
    spotify-tui
    sqlite
    starship # ☄🌌️ The minimal, blazing-fast, and infinitely customizable prompt for any shell!
    sysstat
    terraformer
    tflint
    tldr # A collection of community-maintained help pages for command-line tools
    tokei # compiled with serialization support: json, cbor, yaml
    tree # Recursive directory listing command
    wslu # A collection of utilities for Windows 10 Linux Subsystems
    wireshark
    yq # Command-line YAML processor - jq wrapper for YAML documents
  ];
  alternative = [
    bat # A cat(1) clone with syntax highlighting and Git integration
    broot # A new way to see and navigate directory trees
    colordiff # Compare FILES line by line.hto
    exa # A modern replacement for the venerable file-listing command-line program
    fd # A simple, fast and user-friendly alternative to 'find'
    gping # Ping, but with a graph
    htop # A cross-platform interactive process viewer
    procs # A modern replacement for ps written in Rust
    ripgrep # An interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
  ];
in
db ++ modern ++ alternative
