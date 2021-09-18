{ pkgs, ... }:

{
  enable = true;
  package = pkgs.neovim-unwrapped;
}
