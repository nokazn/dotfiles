{ pkgs, lib, ... }:

let
  fileSourceList =
    let
      toSourcePath = file: builtins.toString ../../.. + ("/" + file);
      files =
        let
          files = builtins.readFile ./files.txt;
        in
        builtins.filter
          (file:
            let
              # プロジェクトルート基準でファイルが存在するか
              exists = builtins.pathExists (toSourcePath file);
              # `# `で始まるファイルはhome-managerによって生成されるのでここでは無視する
              ignored = (builtins.match "^#\s+.+" file) != null;
            in
            file != "" && exists && !ignored
          )
          (lib.splitString "\n" files);
      onChange = file:
        if (!pkgs.stdenv.isDarwin) then ''
          chmod +w ${file}
        '' else "";
    in
    builtins.map
      (file: {
        name = file;
        value = {
          # https://discourse.nixos.org/t/how-to-refer-to-current-directory-in-shell-nix/9526
          source = toSourcePath file;
          target = file;
          # TODO: darwinでも対応できるようにする
          onChange = onChange file;
        };
      })
      files;
in
builtins.listToAttrs fileSourceList
