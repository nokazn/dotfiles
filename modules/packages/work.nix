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
      enableLangs = false;
    };
  };
in
with pkgs;
langs
++ lib.attrValues {
  cli = lib.attrValues {
    db = [
      mysql80
    ];
  };
}
