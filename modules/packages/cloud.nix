{ pkgs, ... }:

with pkgs;
[
  aws-mfa # Manage AWS MFA Security Credentials
  aws-vault # A vault for securely storing and accessing AWS credentials in development environments
  awscli2
  nodePackages.aws-cdk
]
++ lib.optionals (!stdenv.isDarwin) [
  # TODO: ビルドが落ちる
  # wrangler # A CLI tool designed for folks who are interested in using Cloudflare Workers
]
