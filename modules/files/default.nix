{ pkgs, lib, ... }:

let
  fileSourceList =
    let
      toSourcePath = file: builtins.toString ./../../unix + ("/" + file);
      files =
        let
          files = builtins.readFile ./files.txt;
        in
        builtins.filter
          (file:
            let
              # `# `で始まるファイルはhome-managerによって生成されるのでここでは無視する
              ignored = (builtins.match "^#[[:space:]]+(.+)" file) != null;
              # プロジェクトルート基準でファイルが存在するか
              exists = builtins.pathExists (toSourcePath file);
              copiable =
                if !ignored && !exists then
                  throw "No file: ${file}"
                else !ignored && exists;
            in
            file != "" && copiable
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
