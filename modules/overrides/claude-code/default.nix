# nixpkgs の claude-code を最新バージョンで override するパッケージ定義
#
# 更新手順 (`make update/claude-code` で自動化済み):
#   1. npm から最新バージョンを取得
#   2. tarball をダウンロードし package-lock.json を生成
#   3. nix hash で src の hash を計算
#   4. overrideVersion と hash を更新
#   5. npmDepsHash に fakeHash を設定してビルドし、正しいハッシュをエラーから取得
#   6. npmDepsHash を更新
#   7. git add modules/overrides/claude-code/package-lock.json (flake が参照するため必須)
{
  lib,
  claude-code,
  fetchzip,
  fetchNpmDeps,
}:
let
  overrideVersion = "2.1.80";
  overridden = claude-code.overrideAttrs (oldAttrs: rec {
    version = overrideVersion;
    src = fetchzip {
      url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
      hash = "sha256-0Jdr7e4QcWzEWrezOfqTQW3s0w2xlUA4tVScY0y/zI8=";
    };
    postPatch = ''
      cp ${./package-lock.json} package-lock.json
      substituteInPlace cli.js \
        --replace-fail '#!/bin/sh' '#!/usr/bin/env sh'
    '';
    npmDepsHash = "sha256-4zW3sGw/3tKZJa+2VikHYuHFEVoNyyjorHQ/rC6Xvm0=";
    npmDeps = fetchNpmDeps {
      inherit src postPatch;
      name = "claude-code-${version}-npm-deps";
      hash = npmDepsHash;
    };
  });
in
if lib.versionAtLeast claude-code.version overrideVersion then claude-code else overridden
