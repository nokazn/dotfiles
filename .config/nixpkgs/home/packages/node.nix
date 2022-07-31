{ pkgs, ... }:

with pkgs.nodePackages; [
  eslint
  firebase-tools
  gulp
  jake
  lerna
  node-gyp
  prettier
  pyright
  serverless
  typescript
  vercel
  webpack-cli
]
