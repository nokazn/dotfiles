{ pkgs, lib, ... }:

with pkgs; lib.attrValues {
  langs = [
    asdf-vm # Extendable version manager with support for Ruby, Node.js, Erlang & more
    cue # A data constraint language which aims to simplify tasks involving defining and using data
    erlang
    lua
    nim
    powershell # Powerful cross-platform (Windows, Linux, and macOS) shell and scripting language based on .NET
    yamlfmt # An extensible command line tool or library to format yaml files.
  ];
  node = with nodePackages;[
    eslint
    firebase-tools
    gulp
    jake
    node-gyp
    prettier
    pyright
    serverless
    typescript
    vercel
    webpack-cli
  ];
  js = [
    biome # Toolchain of the web
    deno
    dprint # Code formatting platform written in Rust
    oxlint # A suite of high-performance tools for JavaScript and TypeScript written in Rust
  ];
  rust =
    let
      libiconv =
        if stdenv.isDarwin then pkgs.darwin.libiconv
        else pkgs.libiconv;
    in
    [
      cargo-cache
      rustup
      libiconv
    ];
  go = [
    ghq
    gotools
    gopls
    gore
  ];
  elm = with elmPackages;[
    elm
    elm-format
  ];
  java = [
    jdk11
    maven
  ];
  php = [
    php
    php81Packages.composer
  ];
  python = [
    black
    isort
    pipenv
    poetry
    python312
  ] ++ lib.optionals (!stdenv.isDarwin) (with python312Packages; [
    flake8
    setuptools
  ]);
  shellscript = [
    shellcheck # A static analysis tool for shell scripts
    shfmt # A shell parser and formatter
  ];
}
