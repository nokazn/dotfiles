{ pkgs, ... }:

with pkgs ; [
  awscli2
  google-cloud-sdk
  heroku
  netlify-cli
  wrangler # A CLI tool designed for folks who are interested in using Cloudflare Workers
]
