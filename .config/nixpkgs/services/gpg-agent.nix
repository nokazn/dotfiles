{ ... }:

let
  # 1年間
  ttl = 60 * 60 * 24 * 365;
in
{
  enable = true;
  enableBashIntegration = true;
  enableFishIntegration = true;
  enableZshIntegration = true;
  defaultCacheTtl = ttl;
  maxCacheTtl = ttl;
  pinentryFlavor = "tty";
}
