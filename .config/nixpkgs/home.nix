{ config, pkgs, ... }:

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
  home.packages = with pkgs; [
    # Git tools  ----------------------------------------------------------------------------------------------------
    git
    gitAndTools.gh                    # Work seamlessly with GitHub from the command line
    gitAndTools.delta                 # viewer for git and diff output
    gist                              # Gist lets you upload to https://gist.github.com/
    # specific language related tools ----------------------------------------------------------------------------------------------------
    php
    php74Packages.composer
    yarn
    # CLI tools for public cloud services ----------------------------------------------------------------------------------------------------
    google-cloud-sdk
    awscli2
    heroku
    # GUI Apps ----------------------------------------------------------------------------------------------------
    google-chrome
    # classic CLI tools ----------------------------------------------------------------------------------------------------
    gcc
    vimHugeX
    gnome.gedit                       # The default text editor of the GNOME desktop environment and part of the GNOME Core Applications
    tmux
    rsync
    xfce.thunar                       # A file manager for Linux and other Unix-like systems
    inetutils
    sl
    zip
    unzip
    tree                              # Recursive directory listing command
    redis
    memcached
    # modern CLI tools ----------------------------------------------------------------------------------------------------
    neofetch                          # CLI system information tool written in BASH that displays information about your system next to an image, your OS logo, or any ASCII file of your choice
    direnv
    nkf                               # A Kanji code converter among networks
    shellcheck                        # A static analysis tool for shell scripts
    expect
    tldr                              # A collection of community-maintained help pages for command-line tools
    jq                                # A lightweight and flexible command-line JSON processor
    yq                                # Command-line YAML processor - jq wrapper for YAML documents
    tokei                             # compiled with serialization support: json, cbor, yaml
    mkcert                            # A simple zero-config tool to make locally trusted development certificates with any names you'd like.
    lazygit                           # A simple terminal UI for git commands
    lazydocker                        # The lazier way to manage everything docker
    dive                              # A tool for exploring each layer in a docker image
    ncdu                              # A disk usage analyzer with an ncurses interface
    pastel                            # A command-line tool to generate, analyze, convert and manipulate colors
    act                               # Run your GitHub Actions locally 噫
    hyperfine                         # A command-line benchmarking tool
    powershell
    # modern command replacements ----------------------------------------------------------------------------------------------------
    colordiff                         # Compare FILES line by line.hto
    htop                              # A cross-platform interactive process viewer
    bat                               # A cat(1) clone with syntax highlighting and Git integration
    exa                               # A modern replacement for the venerable file-listing command-line program
    fd                                # A simple, fast and user-friendly alternative to 'find'
    ripgrep                           # An interactive replacer for ripgrep that makes it easy to find and replace across files on the command line
    broot                             # A new way to see and navigate directory trees
    gping                             # Ping, but with a graph
  ];

  home.file = {
    # ".config/git/attributes".source = ../../.config/git/attributes;
    # ".config/git/igonre".source = ../../.config/git/igonre;
    ".bash_aliases".source = ../../.bash_aliases;
    ".bash_profile".source = ../../.bash_profile;
    ".bashrc".source = ../../.bashrc;
    ".gitconfig".source = ../../.gitconfig;
    ".npmrc".source = ../../.npmrc;
    ".path.sh".source = ../../.path.sh;
    ".prettierrc.json".source = ../../.prettierrc.json;
    ".profile".source = ../../.profile;
    ".shellcheckrc".source = ../../.shellcheckrc;
    ".shrc.sh".source = ../../.shrc.sh;
    ".tmux.conf".source = ../../.tmux.conf;
    ".vimrc".source = ../../.vimrc;
    ".zlogin".source = ../../.zlogin;
    ".zlogout".source = ../../.zlogout;
    # ".zpreztorc".source = ../../.zpreztorc;
    ".zprofile".source = ../../.zprofile;
    ".zshenv".source = ../../.zshenv;
    ".zshrc".source = ../../.zshrc;
  };

  programs.zsh = {
    enable = true;
  };

  programs.zsh.prezto = {
    enable = true;
    color = true;
    # the Prezto modules to load (browse modules)
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

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };
}
