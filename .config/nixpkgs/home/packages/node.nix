{ pkgs, ... }:

with pkgs.nodePackages; [
  eslint
  firebase-tools
  lerna
  # TODO: ビルドできない
  # netlify-cli
  node-gyp
  prettier
  serverless
  typescript
  webpack-cli
  yarn
]
