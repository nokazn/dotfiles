{ pkgs, ... }:

# 更新は `make update/npm-packages`（nix-update）で行うため、各パッケージは nix-update が書き換えられる `version` と `hash` の形を保つ
let
  nodejs = pkgs.nodejs_26;
in
{
  sort-package-json = pkgs.buildNpmPackage rec {
    inherit nodejs;
    pname = "sort-package-json";
    version = "4.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "keithamus";
      repo = "sort-package-json";
      rev = "v${version}";
      hash = "sha256-dqk0BypmVx23FTaTvq46MxAI+Tr0Q66xR4srwpi4Kfs=";
    };

    npmDepsHash = "sha256-YqQXrWUi9+Gf8Ni2qcFy/cl3OOsI255/gt0tMDhqpko=";

    dontNpmBuild = true;
  };

  http-server = pkgs.buildNpmPackage rec {
    inherit nodejs;
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
  };

  # GitHub のソースには webpack ビルド成果物 `dist/cli.js` がコミットされておらず、実行時依存も無いため、ビルド済みの npm 公開物をそのまま使う
  envinfo = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "envinfo";
    version = "7.21.0";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/envinfo/-/envinfo-${finalAttrs.version}.tgz";
      hash = "sha256-WHgGps18jKpwHTVugGr+bBaZ87L/p6hGsE0Y9uM1+Dw=";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/envinfo
      cp -r . $out/lib/node_modules/envinfo/
      makeWrapper ${nodejs}/bin/node $out/bin/envinfo \
        --add-flags $out/lib/node_modules/envinfo/dist/cli.js
      runHook postInstall
    '';
  });

  skills = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "skills";
    version = "1.8.1";

    src = pkgs.fetchFromGitHub {
      owner = "vercel-labs";
      repo = "skills";
      rev = "v${finalAttrs.version}";
      hash = "sha256-K4xCSpt8jnkTx8FDEa2cXrzMjpRkYOwTiFqPap6iCYU=";
    };

    nativeBuildInputs = [
      nodejs
      pkgs.makeWrapper
      pkgs.pnpmConfigHook
      pkgs.pnpm_10
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pkgs.pnpm_10;
      fetcherVersion = 3;
      hash = "sha256-cL9mQpQZ5/kbrdZ9TWhymz8iVxdtb9YSdstiVBMejTU=";
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
      rm -rf node_modules
      pnpm install --offline --prod --frozen-lockfile --ignore-scripts
      mkdir -p $out/lib/node_modules/skills
      cp -r dist bin package.json node_modules $out/lib/node_modules/skills/
      makeWrapper ${nodejs}/bin/node $out/bin/skills \
        --add-flags $out/lib/node_modules/skills/bin/cli.mjs
      ln -s $out/bin/skills $out/bin/add-skill
      runHook postInstall
    '';
  });
}
