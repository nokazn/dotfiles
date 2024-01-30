{ pkgs, ... }:

{
  enable = true;
  packages = {
    "github.com/ktr0731/salias" = pkgs.fetchFromGitHub {
      owner = "ktr0731";
      repo = "salias";
      rev = "v0.1.0";
      hash = "sha256-OIUpDAISExfOZqoE1aXv5l8qBiOQyFk9CQVPrv0wydU=";
    };
  };
}
