{ pkgs, ... }:

{
  enable = true;
  package = pkgs.tmux;
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
