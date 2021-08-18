{ config, ... }:

let
  files = builtins.readFile ./files.txt;
  fileSourceList = builtins.map (file: {
    name = file;
    value = {
      source = config.lib.file.mkOutOfStoreSymlink ../../.. + ("/" + file);
    };
  }) files;
in builtins.listToAttrs fileSourceList
