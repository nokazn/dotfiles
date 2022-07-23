{ pkgs, ... }:

{
  enable = false;
  package = pkgs.neovim-unwrapped;
  viAlias = true;
  vimAlias = true;
  extraPackages = with pkgs; [
    tree-sitter
    rnix-lsp
    nodePackages.typescript
    nodePackages.typescript-language-server
  ];
  coc = {
    enable = true;
  };
  withPython3 = true;
  withNodeJs = true;

  plugins = with pkgs; [
    {
      plugin = vimPlugins.gina-vim;
    }
    {
      plugin = vimPlugins.fern-vim;
    }
  ];
  extraConfig = ''
    set undofile
    set undodir=~/.vim/undodir
  '';
}
