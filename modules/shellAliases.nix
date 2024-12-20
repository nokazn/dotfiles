{ meta, ... }:

let
  DOTFILES = "~/dotfiles";
  wslAliases =
    if meta.isWsl then
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

  # `eza` aliases
  eza = "eza --icons --git";
  ezat = "eza --tree";
  ezal = "eza -l";

  # Git aliases
  g = "git";
  branch = "git symbolic-ref --short HEAD";

  # GPG aliases
  gpg-list-secret-key-ids = "gpg --list-secret-keys --keyid-format LONG | grep -E '^sec' | awk '{ print $2 }' | sed -E 's/^.+\\///'";
  gpg-agent-reload = "gpgconf --kill gpg-agent";

  # Nix
  nixpkgs-review-pr = "nixpkgs-review pr --post-result $(gh pr view --json number -q .number)";

  # custom aliases
  apt-install = "apt install --no-install-recommends";
  apt-purge = "apt --purge remove";
  dc = "docker";
  dcc = "docker compose";
  diff = "colordiff";
  dotfiles = "cd ${DOTFILES}";
  hm = "home-manager";
  lg = "lazygit";
  makepkg = "makepkg -sric";
  nix-shell = "nix-shell --run $SHELL";
  nix-cg = "nix-collect-garbage";
  reload-tmux = "tmux source-file ~/.config/tmux/tmux.conf";
  relogin = "exec $SHELL -l";
  repath = "source ~/.path.sh";
  sampler = "sampler -c ~/.config/sampler/config.yml";
  ssh-keygen-rsa = "ssh-keygen -t rsa -b 4096 -C";
  tf = "terraform";
  tarx = "tar -xvz";
  y = "yarn";

  dball = "mysql -uroot -h 127.0.0.1 -P 3307 -p tunecorejapan -A -ppassword";
  tailfsite = "docker exec tcj-ap-server tail -f /var/log/tunecorejapan/site/error/current";
  tailfadmin = "docker exec tcj-ap-server tail -f /var/log/tunecorejapan/admin/error/current";
  tailfgo = "docker exec tcj-go-server tail -f /var/log/tunecorejapan_go/site/error/current";
  tailflinkcore = "docker exec tcj-go-server tail -f /var/log/tunecorejapan_go/linkcore/error/current";
  tailfdynamo = "docker exec tcj-go-server tail -f /var/log/tunecorejapan_go/dynaprox/error/current";
} // wslAliases
