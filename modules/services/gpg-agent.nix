{ pkgs, meta, ... }:

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
  pinentry = {
    package =
      if meta.isWsl then
        pkgs.pinentry-curses
      else if pkgs.stdenv.isLinux then
        pkgs.pinentry-qt
      else
        null;
  };
}
