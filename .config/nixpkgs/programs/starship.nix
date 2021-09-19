{ ... }:

{
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
    aws.disabled = true;

    package.disabled = true;
  };
}
