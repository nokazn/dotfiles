{ pkgs, ... }:

{
  enable = true;
  package = pkgs.tmux;
  keyMode = "vi";
  # 0 にすると謎の文字が出現する (https://github.com/microsoft/WSL/issues/5931)
  escapeTime = 500;
  extraConfig =
    let
      tmuxConf = builtins.toString ../../../.tmux.conf;
    in
    builtins.readFile tmuxConf;
  plugins = with pkgs; [
    {
      # A set of tmux options that should be acceptable to everyone
      plugin = tmuxPlugins.sensible;
    }
    {
      # Saves all the little details from your tmux environment
      plugin = tmuxPlugins.resurrect;
    }
    {
      # Copying to system clipboard
      plugin = tmuxPlugins.yank;
    }
  ];
}
