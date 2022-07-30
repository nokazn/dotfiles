{ pkgs, ... }:

with pkgs.nodePackages; [
  eslint
  firebase-tools
  gulp
  lerna
  node-gyp
  prettier
  pyright
  serverless
  ts-node
  typescript
  vercel
  webpack-cli
]
