{ pkgs, lib, ... } @args:

let
  meta = {
    enableElm = false;
    enableJava = false;
    enablePhp = false;
    enablePython = true;
    enableLangs = true;
  } // args.meta;
in
with pkgs;
lib.attrValues {
  meta = [
    asdf-vm # Extendable version manager with support for Ruby, Node.js, Erlang & more
    proto # A pluggable multi`-language version manager
  ];
  node = with nodePackages;[
    eslint
    node-gyp
    prettier
    serverless
    typescript
    webpack-cli
  ];
  js = [
    biome # Toolchain of the web
    bun # Incredibly fast JavaScript runtime, bundler, transpiler and package manager – all in one
    deno
    dprint # Code formatting platform written in Rust
    oxlint # A suite of high-performance tools for JavaScript and TypeScript written in Rust
    turbo # High-performance build system for JavaScript and TypeScript codebases
    nodejs
  ];
  rust =
    let
      libiconv =
        # `LD_LIBRARY_PATH`と`LIBRARY_PATH`を設定する必要がある
        if stdenv.isDarwin then pkgs.darwin.libiconv
        else pkgs.libiconv;
    in
    [
      cargo-cache
      cargo-watch
      rustup
      libiconv
      evcxr # An evaluation context for Rust
    ];
  go = [
    ghq
    gotools
    gopls
    gore
  ];
  elm = with elmPackages; lib.optionals meta.enableElm [
    elm
    elm-format
  ];
  java = lib.optionals meta.enableJava [
    jdk11
    maven
  ];
  php = lib.optionals meta.enablePhp [
    php
    php81Packages.composer
  ];
  python = lib.optionals meta.enablePython ([
    black
    isort
    pipenv
    poetry
    python312
    ruff
    pyright
  ] ++ (with python312Packages; [
    setuptools
    flake8
  ]));
  shellscript = [
    shellcheck # A static analysis tool for shell scripts
    shfmt # A shell parser and formatter
  ];
  config = [
    lua
    yamlfmt # An extensible command line tool or library to format yaml files.
  ];
  terraform = [
    terraformer
  ];
  langs = lib.optionals meta.enableLangs [
    cue # A data constraint language which aims to simplify tasks involving defining and using data
    erlang
    nim
    powershell
  ];
}
