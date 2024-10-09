{ ... }:

{
  trackpad = {
    ActuationStrength = 0;
    Dragging = true;
    Clicking = true;
  };

  dock = {
    orientation = "left";
    autohide = false;
    # Whether to automatically rearrange spaces based on most recent use. The default is true.
    mru-spaces = false;
  };

  finder = {
    ShowPathbar = true;
    ShowStatusBar = true;
  };

  menuExtraClock = {
    ShowSeconds = true;
  };

  NSGlobalDomain = {
    AppleInterfaceStyle = "Dark";
    AppleShowAllFiles = true;
    "com.apple.swipescrolldirection" = true;
    "com.apple.keyboard.fnState" = true;
  };
}
