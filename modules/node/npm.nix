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

  skills = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "skills";
    version = "1.3.9";

    src = pkgs.fetchFromGitHub {
      owner = "vercel-labs";
      repo = "skills";
      rev = "v${finalAttrs.version}";
      hash = "sha256-JidfLICAkXY1xEUSGcRZbS88x50cxyZcG9uRFASqOqI=";
    };

    nativeBuildInputs = [
      pkgs.nodejs_22
      pkgs.pnpmConfigHook
      pkgs.pnpm_10
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 3;
      hash = "sha256-pwPJ4CRHEtCXpt5b6g/7EbDsUc2KCjOtpiVED0tqoMk=";
    };

    buildPhase = ''
      runHook preBuild
      # Skip license generation as it requires network access
      # Just run obuild directly instead of the full build script
      pnpm obuild
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/skills
      cp -r dist bin package.json $out/lib/node_modules/skills/
      mkdir -p $out/bin
      ln -s $out/lib/node_modules/skills/bin/cli.mjs $out/bin/skills
      ln -s $out/lib/node_modules/skills/bin/cli.mjs $out/bin/add-skill
      runHook postInstall
    '';
  });
}
