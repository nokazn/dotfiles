{ pkgs, lib, ... }@args:

let
  meta = {
    enableElm = false;
    enableJava = false;
    enablePhp = false;
    enablePython = true;
    enableTerraform = false;
    enableLangs = false;
    enableOptional = false;
  }
  // args.meta;
in
with pkgs;
lib.attrValues {
  meta = [
    proto # A pluggable multi`-language version manager
  ];
  node = [
    fnm
    eslint
    node-gyp
    prettier
    typescript
  ];
  js = [
    dprint # Code formatting platform written in Rust
    oxlint # A suite of high-performance tools for JavaScript and TypeScript written in Rust
  ];
  rust =
    let
      libiconv =
        # `LD_LIBRARY_PATH`と`LIBRARY_PATH`を設定する必要がある
        if stdenv.isDarwin then pkgs.darwin.libiconv else pkgs.libiconv;
    in
    [
      cargo-cache
      cargo-watch
      rustup
      libiconv
      pkg-config
    ];
  go = [
    ghq
    gotools
    gopls
    gore
  ];
  elm =
    with elmPackages;
    lib.optionals meta.enableElm [
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
  python = lib.optionals meta.enablePython (
    [
      isort
      pipenv
      ruff
      pyright
    ]
    ++ (with python3Packages; [
      setuptools
    ])
  );
  shellscript = [
    shellcheck # A static analysis tool for shell scripts
    shfmt # A shell parser and formatter
  ];
  config = [
    lua
    yamlfmt # An extensible command line tool or library to format yaml files.
  ];
  terraform = lib.optionals meta.enableTerraform [
    terraformer
  ];
  langs = lib.optionals meta.enableLangs [
    cue # A data constraint language which aims to simplify tasks involving defining and using data
    nim
    powershell
  ];
  # Kept out by default because each pulls in a large closure on every nixpkgs update
  optional = lib.optionals meta.enableOptional [
    black
    deno
    erlang
    evcxr # An evaluation context for Rust
  ];
}
