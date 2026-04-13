{ meta, ... }:
{
  enable = true;
  casks = [
    "alfred"
    "battery"
    "clipy"
    "copilot-cli"
    "docker-desktop"
    "firefox"
    "google-chrome"
    "homebrew/cask/font-hackgen-nerd"
    "homebrew/cask/font-hackgen"
    "karabiner-elements"
    "keepassxc"
    "keycastr"
    "logi-options+"
    "notion"
    "slack"
    "spotify"
    "todoist-app"
    "visual-studio-code"
    "wezterm"
    "zed"
  ]
  ++ (
    if meta.profile == "private" then
      [
        "bluesnooze"
        "discord"
        "google-drive"
        "keybase"
        "lastfm"
        "zoom"
      ]
    else
      [ ]
  );
}
