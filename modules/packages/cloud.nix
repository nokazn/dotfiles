{ pkgs, ... }:

with pkgs;
[
  aws-mfa # Manage AWS MFA Security Credentials
  aws-vault # A vault for securely storing and accessing AWS credentials in development environments
  awscli2
  google-cloud-sdk
  nodePackages.vercel
]
++ lib.optionals (!stdenv.isDarwin) [
  wrangler # A CLI tool designed for folks who are interested in using Cloudflare Workers
]
