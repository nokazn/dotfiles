{ pkgs, ... }:

let
  entries = builtins.readDir ./.;

  # `<some-package>/default.nix`
  dirOverrides = builtins.filter (
    name: entries.${name} == "directory" && builtins.pathExists (./${name}/default.nix)
  ) (builtins.attrNames entries);

  # `<some-package>.nix`
  fileOverrides = builtins.filter (
    name: name != "default.nix" && builtins.match ".+\\.nix$" name != null
  ) (builtins.attrNames entries);

  dirAttrs = builtins.listToAttrs (
    builtins.map (name: {
      name = name + "-override";
      value = pkgs.callPackage (./${name}) { };
    }) dirOverrides
  );

  fileAttrs = builtins.listToAttrs (
    builtins.map (name: {
      name = builtins.replaceStrings [ ".nix" ] [ "-override" ] name;
      value = pkgs.callPackage (./${name}) { };
    }) fileOverrides
  );
in
# ファイル（`<some-package>.nix`） > ディレクトリ（`<some-package>/default.nix`）の順で優先
fileAttrs // dirAttrs
