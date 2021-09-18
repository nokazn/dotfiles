{ ... }:

{
  enable = true;
  # TODO: ホームディレクトリにあるだけでは読み込まれない
  extraConfig =
    let
      vimrc = builtins.toString ../../../.vimrc;
    in
    builtins.readFile vimrc;
}
