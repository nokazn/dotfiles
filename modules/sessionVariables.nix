{ pkgs, lib, ... }:

{
  LANG = "en_US.UTF-8";
  LC_ALL = "en_US.utf-8";

  # colored GCC warnings and errors
  GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";

  # editors
  EDITOR = "vim";
  SUDO_EDITOR = "vim";
  VISUAL = "vim";
  PAGER = "less";

  # Set the default Less options.
  # Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
  # Remove -X and -F (exit if the content fits on one screen) to enable it.
  LESS = "-F -g -i -M -R -S -w -X -z-4";

  TAR_OPTIONS = "-xvz";
}
