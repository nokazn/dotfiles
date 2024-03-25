{ pkgs, lib, meta, ... }:

with pkgs; lib.attrValues {
  db = [
    memcached
    redis
    sqlite
  ];
  system = [
    du-dust # du + rust = dust. Like du but more intuitive
    htop # A cross-platform interactive process viewer
    gtop # System monitoring dashboard for the terminal
    ncdu # A disk usage analyzer with an ncurses interface
    procs # A modern replacement for ps written in Rust
    sampler # Tool for shell commands execution, visualization and alerting. Configured with a simple YAML file.
  ];
  dx = [
    direnv
    just # A handy way to save and run project-specific commands
    mkcert # A simple zero-config tool to make locally trusted development certificates with any names you'd like.
    navi # An interactive cheatsheet tool for the command-line and application launchers
    tldr # A collection of community-maintained help pages for command-line tools
    tokei # compiled with serialization support: json, cbor, yaml
    treefmt # one CLI to format the code tree
  ];
  text = [
    jq # A lightweight and flexible command-line JSON processor
    nkf # A Kanji code converter among networks
    yq # Command-line YAML processor - jq wrapper for YAML documents
  ];
  network = [
    gping # Ping, but with a graph
    wireshark # Powerful network protocol analyzer
  ];
  explorer = [
    broot # A new way to see and navigate directory trees
    tree # Recursive directory listing command
  ];
  utilities = [
    asciinema # Terminal session recorder and the best companion of asciinema.org
    hyperfine # A command-line benchmarking tool
    neofetch # CLI system information tool written in BASH that displays information about your system next to an image, your OS logo, or any ASCII file of your choice
    pastel # A command-line tool to generate, analyze, convert and manipulate colors
    sl # SL(1): Cure your bad habit of mistyping
  ];
  alternative = [
    bat # A cat(1) clone with syntax highlighting and Git integration
    colordiff # Compare FILES line by line.hto
    eza # A modern replacement for the venerable file-listing command-line program
    fd # A simple, fast and user-friendly alternative to 'find'
    ripgrep # An interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
  ];
  platform =
    if stdenv.isDarwin then [
      keybase
    ]
    else [
      dstat # Versatile resource statistics tool
      sysstat # A collection of performance monitoring tools for Linux (such as sar, iostat and pidstat)
    ] ++ lib.optional meta.isWsl [
      wslu # A collection of utilities for Windows 10 Linux Subsystems
    ];
}
