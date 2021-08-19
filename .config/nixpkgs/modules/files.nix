{ lib, ... }:

let
  files = builtins.readFile ./files.txt;
  fileList = lib.splitString "\n" files;
  fileSourceList = builtins.map (file: {
    name = file;
    value = {
      source = ../../.. + ("/" + file);
    };
  }) fileList;
in builtins.listToAttrs fileSourceList
