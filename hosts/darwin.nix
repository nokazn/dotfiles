{ user, ... }:

{
  # necessary for nix-darwin
  services.nix-daemon.enable = true;

  users.users = {
    ${user.name} = {
      home = "/Users/${user.name}";
      shell = "zsh";
    };
  };

  homebrew = {
    enable = true;
    taps = [
      "homebrew/cask-fonts"
    ];
    casks = [
      "alfred"
      "discord"
      "firefox"
      "google-chrome"
      "google-drive"
      "iterm2"
      "keepassxc"
      "rambox"
      "slack"
      "spotify"
      "todoist"
      "visual-studio-code"
      "wezterm"
      "zoom"
      "homebrew/cask-fonts/font-hackgen"
      "homebrew/cask-fonts/font-hackgen-nerd"
    ];
  };
}
