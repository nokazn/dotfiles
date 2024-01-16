{ pkgs, ... }:

let
  buildVimPlugin = src: (pkgs.vimUtils.buildVimPlugin {
    name = "${src.owner}/${src.repo}";
    src = pkgs.fetchFromGitHub src;
  });
  customVimPlugins = map buildVimPlugin [
    {
      owner = "itchyny";
      repo = "lightline";
      rev = "1c6b455c0445b8bc1c4c16ba569a43c6348411cc";
      hash = "sha256-aoJR1l+N1kyY5HX0jgCIJfYbAmg/H8vb8mwjDqNnrTc=";
    }
    {
      owner = "joshdick";
      repo = "onedark.vim";
      rev = "57b77747694ea5676c3ca0eeaf9567dc499730c0";
      hash = "sha256-rt/VKABAfxyFBKNerZiswWDaBrusrn7WaI1jHbn3I/s=";
    }
    {
      owner = "pineapplegiant";
      repo = "spaceduck";
      rev = "350491f19343b24fa85809242089caa02d4dadce";
      hash = "sha256-lE8y9BA2a4y0B6O3+NyOS7numoltmzhArgwTAner2fE=";
    }
  ];
in
{
  enable = true;
  packageConfigurable = pkgs.vim;
  plugins = with pkgs.vimPlugins; [
    nerdtree
    gitgutter
  ] ++ customVimPlugins;
  # ホームディレクトリにあるだけでは読み込まれない
  extraConfig =
    let
      # TODO: 同じ階層で管理したい
      vimrc = builtins.toString ../../.vimrc;
    in
    builtins.readFile vimrc;
}
