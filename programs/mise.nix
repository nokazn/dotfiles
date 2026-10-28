{ ... }:

{
  enable = true;
  enableBashIntegration = true;
  enableZshIntegration = true;
  globalConfig.tools = {
    node = "lts";
    yarn = "latest";
    pnpm = "latest";
    go = "latest";
    uv = "latest";
  };
}
