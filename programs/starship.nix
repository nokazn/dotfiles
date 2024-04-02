{ ... }:

let
  pastel = {
    orange = "fg:218";
    pink = "fg:212";
    green = "fg:121";
    yellow = "fg:229";
    cyan = "fg:159";
    purple = "fg:105";
    grey = "fg:240";
  };
  toBold = color: "bold ${color}";
  toBoldStyle = str: color: "[${str}](${toBold color})";
in
{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  enableNushellIntegration = true;

  settings = {
    add_newline = true;
    format =
      let
        toDimmedStyle = target: toBoldStyle target pastel.grey;
      in
      ''
        ${toDimmedStyle "┌"} $username$hostanem$shlvl$directory$git_branch$git_metrics$git_status$git_state$hg_branch$container$docker_context$shell$nix_shell
        ${toDimmedStyle "└"}$jobs$battery$character
      '';
    right_format = "$time";

    username = {
      disabled = false;
      show_always = false;
      style_user = toBold pastel.orange;
      format = "[$user]($style) ";
    };

    hostname = {
      disabled = false;
      ssh_only = true;
      style = toBold pastel.pink;
      format = "@ [$hostname]($style) ";
    };

    shlvl = {
      disabled = false;
      threshold = 3;
      symbol = "↑";
      style = pastel.pink;
      format = "\\([$symbol$shlvl]($style)\\) ";
    };

    directory = {
      disabled = false;
      truncation_length = 3;
      truncate_to_repo = false;
      style = toBold pastel.green;
      format = "[$path]($style)$read_only ";
    };

    memory_usage = {
      disabled = false;
    };

    nix_shell = {
      disabled = false;
    };

    # Git
    git_branch = {
      symbol = "";
      disabled = false;
      style = toBold pastel.cyan;
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
      renamed = "🔃";
      deleted = "🗑️";
      ahead = "⇡$count";
      diverged = "⇡$ahead_count⇣$behind_count";
      behind = "⇣$count";
      style = pastel.cyan;
      format = "\\[[$all_status$ahead_behind]($style)\\] ";
    };
    git_state = {
      disabled = false;
    };

    # Shell
    shell = {
      disabled = false;
      style = pastel.grey;
      format = "[\\($indicator\\)]($style) ";
    };

    docker_context = {
      disabled = false;
    };

    time = {
      disabled = false;
      style = pastel.yellow;
      time_format = "%k:%M:%S";
      format = "[$time]($style)";
    };

    #
    # 2行目
    #

    jobs = {
      disabled = false;
      format = " [$symbol$number]($style)";
    };

    battery = {
      format = " [$symbol$percentage]($style) ";
      display = [
        {
          threshold = 20;
        }
      ];
    };

    character =
      let
        rightWith = toBoldStyle "❯";
        leftWith = toBoldStyle "❮";
      in
      {
        success_symbol = rightWith pastel.green;
        error_symbol = rightWith pastel.pink;
        vicmd_symbol = leftWith pastel.green;
      };

    # Cloud
    aws.disabled = true;
    azure.disabled = true;
    gcloud.disabled = true;
    openstack.disabled = true;
  };
}
