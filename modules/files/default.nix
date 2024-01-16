{ pkgs, lib, ... }:

let
  fileSourceList =
    let
      toSourcePath = file: builtins.toString ./../.. + ("/" + file);
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
    in
    builtins.map
      (file: {
        name = file;
        value = {
          # https://discourse.nixos.org/t/how-to-refer-to-current-directory-in-shell-nix/9526
          source = toSourcePath file;
          target = file;
          onChange = ''
            [[ -f ${file} ]] && chmod +w ${file}
          '';
        };
      })
      files;
in
builtins.listToAttrs fileSourceList
