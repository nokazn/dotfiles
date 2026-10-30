{ pkgs, ... }:

let
  enableOptional = false;
in
with pkgs;
[
  aws-vault # A vault for securely storing and accessing AWS credentials in development environments
  awscli2
]
# Kept out by default because each pulls in a large closure on every nixpkgs update
++ lib.optionals enableOptional [
  aws-mfa # Manage AWS MFA Security Credentials
  google-cloud-sdk
]
++ lib.optionals (!stdenv.isDarwin) [
  # TODO: ビルドが落ちる
  # wrangler # A CLI tool designed for folks who are interested in using Cloudflare Workers
]
