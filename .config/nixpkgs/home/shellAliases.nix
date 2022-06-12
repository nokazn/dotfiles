{ ... }:

let
  DOTFILES = "~/dotfiles";
  wslAliases =
    let
      isWsl = builtins.pathExists /mnt/c;
    in
    if isWsl then
      {
        "explorer.exe" = "/mnt/c/Windows/explorer.exe";
        "bash.exe" = "/mnt/c/Windows/system32/bash.exe";
        "cmd.exe" = "/mnt/c/Windows/system32/cmd.exe";
        "tasklist.exe" = "/mnt/c/Windows/system32/tasklist.exe";
        "clip.exe" = "/mnt/c/Windows/system32/clip.exe";
        clip = "/mnt/c/Windows/system32/clip.exe";
        "wsl.exe" = "/mnt/c/Windows/system32/wsl.exe";
        wsl = "/mnt/c/Windows/system32/wsl.exe";
        "powershell.exe" = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe";
      }
    else
      { };
in
{
  # `ls` aliases
  l = "ls -F";
  la = "ls -A";
  ll = "ls -alF";

  # `exa` aliases
  exa = "exa --icons --git";
  exat = "exa --tree";
  exal = "exa -l";

  # Git aliases
  g = "git";
  branch = "git symbolic-ref --short HEAD";

  # Add an "alert" alias for long running commands.  Use like so:
  # sleep 10; alert
  alert = "notify-send --urgency=low -i \"$([ $? = 0 ] && echo terminal || echo error)\" \"$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')\"";

  # custom aliases
  apt-install = "apt install --no-install-recommends";
  apt-purge = "apt --purge remove";
  dc = "docker";
  dcc = "docker-compose";
  diff = "colordiff";
  dotfiles = "cd ${DOTFILES}";
  hm = "home-manager";
  hmsw = "home-manager switch -f ${DOTFILES}/.config/nixpkgs/home.nix";
  lg = "lazygit";
  nix-shell = "nix-shell --run $SHELL";
  relaod-tmux = "tmux source-file ~/.config/tmux/tmux.conf";
  relogin = "exec $SHELL -l";
  repath = "source ~/.path.sh";
  sampler = "sampler -c ~/.config/sampler/config.yml";
  ssh-keygen-rsa = "ssh-keygen -t rsa -b 4096 -C";
  tf = "terraform";
  z = "zoxide";
} // wslAliases
