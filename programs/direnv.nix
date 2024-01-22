{ ... }:

{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  config = {
    load_dotenv = true;
    strict_env = true;
  };
  nix-direnv = {
    enable = true;
  };
}
