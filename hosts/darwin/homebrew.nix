{ meta, ... }:
{
  enable = true;
  casks = [
    "alfred"
    "battery"
    "clipy"
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
    "rectangle"
    "slack"
    "spotify"
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
        "todoist-app"
        "zoom"
      ]
    else
      [ ]
  );
}
