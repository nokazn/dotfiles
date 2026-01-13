{ pkgs, lib, ... }:

# ハッシュの算出
# 1. `src.hash`
#   `nix-build -E 'with import <nixpkgs> {}; fetchFromGitHub { owner = "オーナー"; repo = "リポジトリ"; rev = "バージョン"; sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; }' 2>&1 | grep "got:"`
# 2. `npmDepsHash:`
#   `npmDepsHash = "";`をセットして、`nix-build --no-out-link -E 'with import <nixpkgs> {}; callPackage ./modules/npm-packages.nix {}' -A パッケージ名`を実行する
{
  sort-package-json = pkgs.buildNpmPackage rec {
    pname = "sort-package-json";
    version = "3.6.0";

    src = pkgs.fetchFromGitHub {
      owner = "keithamus";
      repo = "sort-package-json";
      rev = "v${version}";
      hash = "sha256-Y3za+CCkXf2KK5cRZxupM/1A89weP1uIqk/KqLYBl/w=";
    };

    npmDepsHash = "sha256-dECVKQE7AwAZERSmFhv9qXG+zCSXxSxKBqX/mtFFXFs=";

    dontNpmBuild = true;
    dontFixup = true;
  };

  http-server = pkgs.buildNpmPackage rec {
    pname = "http-server";
    version = "14.1.1";

    src = pkgs.fetchFromGitHub {
      owner = "http-party";
      repo = "http-server";
      rev = "v${version}";
      hash = "sha256-M/YC721QWJfz5sYX6RHm1U9WPHVRBD0ZL2/ceYItnhs=";
    };

    patches = [
      # https://github.com/http-party/http-server/pull/875
      (pkgs.fetchpatch2 {
        name = "regenerate-package-lock.patch";
        url = "https://github.com/http-party/http-server/commit/0cbd85175f1a399c4d13c88a25c5483a9f1dea08.patch";
        hash = "sha256-hJyiUKZfuSaXTsjFi4ojdaE3rPHgo+N8k5Hqete+zqk=";
      })
    ];

    npmDepsHash = "sha256-iUTDdcibnstbSxC7cD5WbwSxQbfiIL2iNyMWJ8izSu0=";

    dontNpmBuild = true;
    dontFixup = true;
  };

  envinfo = pkgs.mkYarnPackage rec {
    pname = "envinfo";
    version = "7.14.0";

    src = pkgs.fetchFromGitHub {
      owner = "tabrindle";
      repo = "envinfo";
      rev = "v${version}";
      hash = "sha256-WC6F4qNQ4mzL6j6D+8LAvXp2VhprEcjQal/Mr3fCOzo=";
    };

    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
  };

  minimum-node-version = pkgs.mkYarnPackage rec {
    pname = "minimum-node-version";
    version = "3.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "hugojosefson";
      repo = "minimum-node-version";
      rev = "v${version}";
      hash = "sha256-ftVP+I2Bk9zvKp1Sv72lVuwSJV1wwN5/TkMD+gvw4lw=";
    };

    packageJSON = "${src}/package.json";
    yarnLock = "${src}/yarn.lock";
  };
}
