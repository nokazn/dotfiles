{ config, pkgs, lib, ... }:

let
  nixPackages = import ./modules/packages.nix { pkgs = pkgs; };
  extraNodePackages = builtins.attrValues (import ./node/default.nix { });
  files = import ./modules/files.nix { lib = lib; };
in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nokazn";
  home.homeDirectory = "/home/nokazn";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  # nix packages
  home.packages = nixPackages ++ extraNodePackages;

  # dotfiles in home directory
  home.file = files;

  # programs settings
  programs.zsh = {
    enable = true;
  };

  programs.zsh.prezto = {
    enable = true;
    color = true;
    # Prezto modules to load (browse modules)
    pmodules = [
      "environment"
      "terminal"
      "editor"
      "history"
      "directory"
      "spectrum"
      "utility"
      "completion"
      "prompt"
      "git"
      "node"
      "tmux"
    ];
    editor.keymap = "vi";
    git.submoduleIgnore = "all";
    prompt.theme = "steeef";
    ssh.identities = [
      "id_rsa"
      "id_rsa2"
      "github"
      "gitlab"
    ];
    syntaxHighlighting.highlighters = [
      "main"
      "brackets"
      "pattern"
      "line"
      "cursor"
      "root"
    ];
  };

  programs.vim = {
    enable = true;
    # TODO: ホームディレクトリにあるだけでは読み込まれない
    extraConfig =
      let
        vimrc = builtins.toString ../../.vimrc;
      in
      builtins.readFile vimrc;
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
  };

  programs.tmux = {
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
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      add_newline = true;

      username = {
        disabled = false;
        show_always = true;
        style_user = "bold fg:217";
        format = "[$user]($style) ";
      };
      hostname = {
        disabled = false;
        ssh_only = true;
        style = "bold fg:212";
        format = "@ [$hostname]($style) ";
      };
      shlvl = {
        disabled = false;
        threshold = 3;
        symbol = "↑";
        style = "fg:212";
        format = "\\([$symbol$shlvl]($style)\\) ";
      };
      directory = {
        disabled = false;
        truncation_length = 5;
        truncate_to_repo = false;
        style = "bold fg:156";
        format = "in [$path]($style)[$read_only]() ";
      };
      memory_usage = {
        disabled = false;
      };
      time = {
        disabled = false;
        style = "fg:229";
        format = "🕙[$time]($style) ";
      };

      git_branch = {
        symbol = "";
        disabled = false;
        style = "bold fg:159";
      };
      git_metrics = {
        disabled = false;
        added_style = "green";
        deleted_style = "red";
        format = "\\([+$added]($added_style) [-$deleted]($deleted_style)\\) ";
      };
      git_status = {
        disabled = false;
        conflicted = "💥";
        up_to_date = "✨";
        untracked = "🔍";
        stashed = "📦";
        modified = "📝";
        deleted = "🗑️";
        ahead = "⇡$count";
        diverged = "⇕⇡$ahead_count⇣$behind_count";
        behind = "⇣$count";
        style = "fg:159";
        format = "\\[[$all_status$ahead_behind]($style)\\] ";
      };
      git_state = {
        disabled = false;
      };

      # 言語
      dotnet = {
        disabled = false;
        heuristic = true;
        format = "via [$symbol($version)]($style) ";
      };
      elm = {
        disabled = false;
        symbol = "🌳Elm ";
        format = "via [$symbol($version)]($style) ";
      };
      # 以下は有効にすると遅くなるので無効にする
      crystal.disabled = true;
      dart.disabled = true;
      deno.disabled = true;
      elixir.disabled = true;
      erlang.disabled = true;
      golang.disabled = true;
      java.disabled = true;
      julia.disabled = true;
      kotlin.disabled = true;
      nim.disabled = true;
      nodejs.disabled = true;
      perl.disabled = true;
      php.disabled = true;
      purescript.disabled = true;
      python.disabled = true;
      rlang.disabled = true;
      ruby.disabled = true;
      rust.disabled = true;
      scala.disabled = true;

      gcloud.disabled = true;

      package.disabled = true;
    };
  };
}
