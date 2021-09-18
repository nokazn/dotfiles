{ lib, ... }:

let
  files = builtins.readFile ./files.txt;
  fileList = lib.splitString "\n" files;
  fileSourceList = builtins.map
    (file: {
      name = file;
      value = {
        # https://discourse.nixos.org/t/how-to-refer-to-current-directory-in-shell-nix/9526
        source = builtins.toString ../../.. + ("/" + file);
      };
    })
    fileList;
in
builtins.listToAttrs fileSourceList
