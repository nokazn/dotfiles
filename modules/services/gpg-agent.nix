{ pkgs, lib, ... }:

let
  # 1年間
  ttl = 60 * 60 * 24 * 365;
in
{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  defaultCacheTtl = ttl;
  maxCacheTtl = ttl;
  pinentryPackage = if pkgs.stdenv.isLinux then pkgs.pinentry else null;
}
