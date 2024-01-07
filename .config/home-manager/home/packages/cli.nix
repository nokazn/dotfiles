{ pkgs, ... }:

with pkgs; let
  db = [
    memcached
    redis
    sqlite
  ];
  modern = [
    asdf-vm # Extendable version manager with support for Ruby, Node.js, Erlang & more
    direnv
    dprint
    dstat
    du-dust # du + rust = dust. Like du but more intuitive
    expect
    gtop
    hyperfine # A command-line benchmarking tool
    jq # A lightweight and flexible command-line JSON processor
    just # A handy way to save and run project-specific commands
    mkcert # A simple zero-config tool to make locally trusted development certificates with any names you'd like.
    navi # An interactive cheatsheet tool for the command-line and application launchers
    ncdu # A disk usage analyzer with an ncurses interface
    neofetch # CLI system information tool written in BASH that displays information about your system next to an image, your OS logo, or any ASCII file of your choice
    nkf # A Kanji code converter among networks
    pastel # A command-line tool to generate, analyze, convert and manipulate colors
    pinentry # GnuPG’s interface to passphrase input
    powershell # Powerful cross-platform (Windows, Linux, and macOS) shell and scripting language based on .NET
    sampler # Tool for shell commands execution, visualization and alerting. Configured with a simple YAML file.
    shellcheck # A static analysis tool for shell scripts
    sl # SL(1): Cure your bad habit of mistyping
    shfmt # A shell parser and formatter
    spotify-tui
    starship # ☄🌌️ The minimal, blazing-fast, and infinitely customizable prompt for any shell!
    sysstat
    tflint
    tldr # A collection of community-maintained help pages for command-line tools
    tokei # compiled with serialization support: json, cbor, yaml
    tree # Recursive directory listing command
    treefmt
    wireshark
    wslu # A collection of utilities for Windows 10 Linux Subsystems
    yq # Command-line YAML processor - jq wrapper for YAML documents
  ];
  alternative = [
    bat # A cat(1) clone with syntax highlighting and Git integration
    broot # A new way to see and navigate directory trees
    colordiff # Compare FILES line by line.hto
    eza # A modern replacement for the venerable file-listing command-line program
    fd # A simple, fast and user-friendly alternative to 'find'
    gping # Ping, but with a graph
    htop # A cross-platform interactive process viewer
    procs # A modern replacement for ps written in Rust
    ripgrep # An interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
  ];
in
db ++ modern ++ alternative
