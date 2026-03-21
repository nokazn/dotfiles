{
  pkgs,
  lib,
  meta,
  ...
}:

let
  langs = import ./_langs.nix {
    inherit pkgs lib;
    meta = {
      enableElm = false;
      enableJava = false;
      enablePhp = false;
      enablePython = true;
      enableTerraform = false;
      enableLangs = true;
    };
  };
in
with pkgs;
langs
++ lib.attrValues {
  cli = lib.attrValues {
    db = [
      memcached
      redis
    ];
  };
  cloud = [
    google-cloud-sdk
    nodePackages.vercel
  ];
  container =
    [ ]
    ++ lib.optionals stdenv.isLinux [
      kubernetes
    ];
  gui =
    [ ]
    ++ lib.optionals stdenv.isLinux [
      # google-chrome
      gedit # The default text editor of the GNOME desktop environment and part of the GNOME Core Applications
      thunar # A file manager for Linux and other Unix-like systems
    ];
  langs = lib.attrValues {
    js = [
      biome # Toolchain of the web
      deno
      turbo # High-performance build system for JavaScript and TypeScript codebases
    ];
  };
}
