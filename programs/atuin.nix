{ ... }:

{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  flags = [
    "--disable-up-arrow"
  ];
  settings = {
    enter_accept = true;
    keymap_mode = "vim-insert";
    show_preview = true;
  };
}
