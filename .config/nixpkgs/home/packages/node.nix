{ pkgs, ... }:

with pkgs.nodePackages; [
  eslint
  firebase-tools
  lerna
  node-gyp
  prettier
  pyright
  serverless
  typescript
  webpack-cli
  yarn
]
