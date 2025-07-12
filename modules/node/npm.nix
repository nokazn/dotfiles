{ pkgs, ... }:

# TODO: node2nixを使わない場合はこちらでビルドする
# ハッシュの算出
# 1. `src.hash`
#   `nix-build -E 'with import <nixpkgs> {}; fetchFromGitHub { owner = "オーナー"; repo = "リポジトリ"; rev = "バージョン"; sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; }' 2>&1 | grep "got:"`
# 2. `npmDepsHash:`
#   `npmDepsHash = "";`をセットして、`nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./modules/npm-packages.nix {}' -A パッケージ名`を実行する
{
  sort-package-json = pkgs.buildNpmPackage rec {
    pname = "sort-package-json";
    version = "2.10.0";

    src = pkgs.fetchFromGitHub {
      owner = "keithamus";
      repo = "sort-package-json";
      rev = "v${version}";
      hash = "sha256-JiOQI3oUH4TaCWd8rx8796vXNhwior380PlQfjQXMzA=";
    };

    npmDepsHash = "sha256-wKs7x1OGX89xT698i3WAz5iNsv71nbmYe8F9DjXO3tI=";

    dontNpmBuild = true;
    dontFixup = true;
  };
}
